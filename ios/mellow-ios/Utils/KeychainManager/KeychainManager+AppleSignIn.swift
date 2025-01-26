//
//  KeychainManager+AppleSignIn.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 01/01/2025.
//

import Foundation

struct UserCredentials: Codable {
    let userID: String
    let fullName: String
    let email: String
}

extension KeychainManager {
    func saveUserCredentials(_ credentials: UserCredentials, account: String) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(credentials)
        try saveCredentials(account: account, credentials: data)
    }
    
    func loadUserCredentials(account: String) throws -> UserCredentials {
        let data = try loadCredentials(account: account)
        let decoder = JSONDecoder()
        return try decoder.decode(UserCredentials.self, from: data)
    }
    
    func deleteUserCredentials(account: String) throws {
        try deleteCredentials(account: account)
    }
}
