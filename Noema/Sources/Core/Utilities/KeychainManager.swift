//
//  KeychainManager.swift
//  Noema
//
//  Created on January 18, 2025.
//

import Foundation
import Security

/// Secure storage manager for encryption keys and sensitive data
public final class KeychainManager {
    public static let shared = KeychainManager()

    private init() {}

    // MARK: - Key Constants

    private let encryptionKeyTag = "com.noema.encryption.key"
    private let service = "com.noema.app"

    // MARK: - Public Methods

    /// Save data to keychain
    public func save(key: String, data: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        // Delete existing item
        SecItemDelete(query as CFDictionary)

        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status: status)
        }
    }

    /// Save string to keychain
    public func save(key: String, string: String) throws {
        guard let data = string.data(using: .utf8) else {
            throw KeychainError.encodingFailed
        }
        try save(key: key, data: data)
    }

    /// Retrieve data from keychain
    public func retrieve(key: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            throw KeychainError.retrievalFailed(status: status)
        }

        guard let data = result as? Data else {
            throw KeychainError.dataConversionFailed
        }

        return data
    }

    /// Retrieve string from keychain
    public func retrieveString(key: String) throws -> String {
        let data = try retrieve(key: key)
        guard let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.decodingFailed
        }
        return string
    }

    /// Delete item from keychain
    public func delete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deletionFailed(status: status)
        }
    }

    /// Check if key exists in keychain
    public func exists(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: false
        ]

        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    /// Clear all keychain items for this app
    public func clearAll() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deletionFailed(status: status)
        }
    }

    // MARK: - Encryption Key Management

    /// Get or create encryption key
    public func getOrCreateEncryptionKey() throws -> Data {
        // Try to retrieve existing key
        if exists(key: encryptionKeyTag) {
            return try retrieve(key: encryptionKeyTag)
        }

        // Generate new key
        let key = try generateEncryptionKey()
        try save(key: encryptionKeyTag, data: key)
        return key
    }

    /// Generate new encryption key (AES-256)
    private func generateEncryptionKey() throws -> Data {
        var bytes = [UInt8](repeating: 0, count: 32) // 256 bits
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)

        guard status == errSecSuccess else {
            throw KeychainError.keyGenerationFailed
        }

        return Data(bytes)
    }
}

// MARK: - Keychain Error

public enum KeychainError: LocalizedError {
    case saveFailed(status: OSStatus)
    case retrievalFailed(status: OSStatus)
    case deletionFailed(status: OSStatus)
    case dataConversionFailed
    case encodingFailed
    case decodingFailed
    case keyGenerationFailed

    public var errorDescription: String? {
        switch self {
        case .saveFailed(let status):
            return "Failed to save to keychain: \(status)"
        case .retrievalFailed(let status):
            return "Failed to retrieve from keychain: \(status)"
        case .deletionFailed(let status):
            return "Failed to delete from keychain: \(status)"
        case .dataConversionFailed:
            return "Failed to convert keychain data"
        case .encodingFailed:
            return "Failed to encode data for keychain"
        case .decodingFailed:
            return "Failed to decode data from keychain"
        case .keyGenerationFailed:
            return "Failed to generate encryption key"
        }
    }
}
