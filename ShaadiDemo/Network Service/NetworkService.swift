//
//  NetworkService.swift
//  ShaadiDemo
//
//  Created by Abhishek Garg on 9/26/25.
//

import Foundation

struct NetworkService {
    
    private let session: URLSession
    
    init(session: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest  = 10 // seconds
        config.timeoutIntervalForResource = 20
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: config)
    }()) {
        self.session = session
    }
    
    func fetchProfiles(count: Int) async throws -> [NetworkProfile] {
        let urlString = "https://randomuser.me/api/"
        print("[API] Starting fetch request for \(count) profiles from: \(urlString)")
        
        var comps = URLComponents(string: urlString)!
        let query: [URLQueryItem] = [URLQueryItem(name: "results", value: String(count))]
        comps.queryItems = query
        
        guard let finalURL = comps.url else {
            print("[API] Failed to construct URL")
            throw NetworkError.emptyData
        }
        
        print("[API] Final URL: \(finalURL.absoluteString)")
        
        var lastError: Error?
        for attempt in 1...3 {
            print("[API] Attempt \(attempt)/3")
            
            do {
                // Actual HTTP call
                let (data, response) = try await session.data(from: finalURL)
                
                if let http = response as? HTTPURLResponse {
                    print("✅ [API] HTTP Status Code: \(http.statusCode)")
                    if !(200...299).contains(http.statusCode) {
                        print("[API] Bad HTTP status: \(http.statusCode)")
                        throw NetworkError.badStatus(http.statusCode)
                    }
                }
                                
                let decoded: RUResponse = try JSONDecoder().decode(RUResponse.self, from: data)
                print("✅ [API] JSON decoding successful, received \(decoded.results.count) profiles")
                
                // Map DTO (Data Transfer Object) -> domain
                let profiles = decoded.results.map { u in
                    NetworkProfile(
                        id: u.login.uuid,
                        fullName: "\(u.name.first) \(u.name.last)",
                        age: u.dob.age,
                        city: u.location.city,
                        imageURL: URL(string: u.picture.large)!
                    )
                }
                
                print("✅ [API] Successfully fetched \(profiles.count) profiles")
                return profiles
                
            } catch {
                let classified: Error
                if error is DecodingError {
                    classified = NetworkError.decoding(error)
                } else if let urlErr = error as? URLError {
                    classified = NetworkError.transport(urlErr)
                } else {
                    classified = error
                }
                
                lastError = classified
                
                if attempt < 3 {
                    let delay = UInt64(300_000_000 * attempt) // 0.3s, 0.6s
                    try? await Task.sleep(nanoseconds: delay)
                    continue
                } else {
                    throw classified
                }
            }
        }
        
        // Should never reach here, but keep compiler happy
        throw lastError ?? NetworkError.emptyData
    }
}
