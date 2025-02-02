//
//  KeychainManager.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 01/01/2025.
//

import Foundation
import Security

struct KeychainManager {
    private let service: String
    private let bundlePrefix: String

    init(service: String = Bundle.main.bundleIdentifier ?? "com.default.keychain") {
        self.service = service
        self.bundlePrefix = (Bundle.main.bundleIdentifier ?? "com.default") + "."
    }
    
    private func prefixedAccountName(for account: String) -> String {
        return bundlePrefix + account
    }
    
    // Save credentials to Keychain
    func saveCredentials(account: String, credentials: Data) throws {
        let prefixedAccount = prefixedAccountName(for: account)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: prefixedAccount,
            kSecValueData as String: credentials
        ]
        
        SecItemDelete(query as CFDictionary) // Remove any existing item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.unableToSave(status: status)
        }
    }
    
    // Retrieve credentials from Keychain
    func loadCredentials(account: String) throws -> Data {
        let prefixedAccount = prefixedAccountName(for: account)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: prefixedAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            throw KeychainError.unableToRetrieve(status: status)
        }
        
        guard let data = result as? Data else {
            throw KeychainError.invalidData
        }
        
        return data
    }
    
    // Delete credentials from Keychain
    func deleteCredentials(account: String) throws {
        let prefixedAccount = prefixedAccountName(for: account)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: prefixedAccount
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unableToDelete(status: status)
        }
    }
}

// MARK: - KeychainError

enum KeychainError: Error {
    case unableToSave(status: OSStatus)
    case unableToRetrieve(status: OSStatus)
    case invalidData
    case unableToDelete(status: OSStatus)
}
