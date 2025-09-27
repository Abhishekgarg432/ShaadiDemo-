//
//  Model.swift
//  ShaadiDemo
//
//  Created by Abhishek Garg on 9/26/25.
//

import Foundation

struct NetworkProfile {
    let id: String
    let fullName: String
    let age: Int
    let city: String
    let imageURL: URL
}

// RandomUser
struct RUResponse: Decodable {
    let results: [RUUser]
}

struct RUUser: Decodable {
    let login: RULogin
    let name: RUName
    let dob: RUDOB
    let location: RULocation
    let picture: RUPicture
}

struct RULogin: Decodable { let uuid: String }
struct RUName: Decodable { let first: String; let last: String }
struct RUDOB: Decodable { let age: Int }
struct RULocation: Decodable { let city: String }
struct RUPicture: Decodable { let large: String }

enum NetworkError: LocalizedError {
    case badStatus(Int)
    case emptyData
    case decoding(Error)
    case transport(Error)

    var errorDescription: String? {
        switch self {
        case .badStatus(let code): return "Server responded with \(code)."
        case .emptyData:          return "No data received from server."
        case .decoding(let e):    return "Failed to decode response: \(e.localizedDescription)"
        case .transport(let e):   return "Network error: \(e.localizedDescription)"
        }
    }
}
