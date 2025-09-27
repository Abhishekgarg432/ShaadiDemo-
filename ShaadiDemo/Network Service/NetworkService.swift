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
        var comps = URLComponents(string: "https://randomuser.me/api/")!
        let query: [URLQueryItem] = [URLQueryItem(name: "results", value: String(count))]
        comps.queryItems = query
        
        var lastError: Error?
        for attempt in 1...3 {
            do {
                // Actual HTTP call
                let (data, response) = try await session.data(from: comps.url!)
                
                if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                    throw NetworkError.badStatus(http.statusCode)
                }
                
                let decoded: RUResponse = try JSONDecoder().decode(RUResponse.self, from: data)
                
                // Map DTO (Data Transfer Object) -> domain
                return decoded.results.map { u in
                    NetworkProfile(
                        id: u.login.uuid,
                        fullName: "\(u.name.first) \(u.name.last)",
                        age: u.dob.age,
                        city: u.location.city,
                        imageURL: URL(string: u.picture.large)!
                    )
                }
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
                    try? await Task.sleep(nanoseconds: UInt64(300_000_000 * attempt)) // 0.3s, 0.6s
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
