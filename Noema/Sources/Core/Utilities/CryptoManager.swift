//
//  CryptoManager.swift
//  Noema
//
//  Created on January 18, 2025.
//

import Foundation
import CryptoKit

/// Manager for encryption and decryption using AES-256-GCM
public final class CryptoManager {
    public static let shared = CryptoManager()

    private let keychainManager = KeychainManager.shared
    private var encryptionKey: SymmetricKey?

    private init() {}

    // MARK: - Initialization

    /// Initialize encryption key
    public func initialize() throws {
        let keyData = try keychainManager.getOrCreateEncryptionKey()
        encryptionKey = SymmetricKey(data: keyData)
    }

    // MARK: - Encryption

    /// Encrypt string
    public func encrypt(string: String) throws -> String {
        guard let data = string.data(using: .utf8) else {
            throw CryptoError.encodingFailed
        }

        let encrypted = try encrypt(data: data)
        return encrypted.base64EncodedString()
    }

    /// Encrypt data
    public func encrypt(data: Data) throws -> Data {
        guard let key = encryptionKey else {
            try initialize()
            guard let key = encryptionKey else {
                throw CryptoError.keyNotInitialized
            }
            return try encryptWithKey(data: data, key: key)
        }

        return try encryptWithKey(data: data, key: key)
    }

    private func encryptWithKey(data: Data, key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: key)

        guard let combined = sealedBox.combined else {
            throw CryptoError.encryptionFailed
        }

        return combined
    }

    // MARK: - Decryption

    /// Decrypt string
    public func decrypt(string: String) throws -> String {
        guard let data = Data(base64Encoded: string) else {
            throw CryptoError.decodingFailed
        }

        let decrypted = try decrypt(data: data)

        guard let string = String(data: decrypted, encoding: .utf8) else {
            throw CryptoError.decodingFailed
        }

        return string
    }

    /// Decrypt data
    public func decrypt(data: Data) throws -> Data {
        guard let key = encryptionKey else {
            try initialize()
            guard let key = encryptionKey else {
                throw CryptoError.keyNotInitialized
            }
            return try decryptWithKey(data: data, key: key)
        }

        return try decryptWithKey(data: data, key: key)
    }

    private func decryptWithKey(data: Data, key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        let decrypted = try AES.GCM.open(sealedBox, using: key)
        return decrypted
    }

    // MARK: - Hashing

    /// Generate SHA256 hash
    public func hash(string: String) -> String {
        guard let data = string.data(using: .utf8) else {
            return ""
        }
        return hash(data: data)
    }

    /// Generate SHA256 hash
    public func hash(data: Data) -> String {
        let hashed = SHA256.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }

    // MARK: - Key Rotation

    /// Rotate encryption key (re-encrypt all data with new key)
    public func rotateKey() throws {
        let newKeyData = try generateNewKey()
        let newKey = SymmetricKey(data: newKeyData)

        // Save new key
        try keychainManager.save(key: "com.noema.encryption.key", data: newKeyData)

        // Update in-memory key
        encryptionKey = newKey
    }

    private func generateNewKey() throws -> Data {
        var bytes = [UInt8](repeating: 0, count: 32) // 256 bits
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)

        guard status == errSecSuccess else {
            throw CryptoError.keyGenerationFailed
        }

        return Data(bytes)
    }

    // MARK: - Secure Random

    /// Generate secure random data
    public func secureRandomData(count: Int) throws -> Data {
        var bytes = [UInt8](repeating: 0, count: count)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)

        guard status == errSecSuccess else {
            throw CryptoError.randomGenerationFailed
        }

        return Data(bytes)
    }

    /// Generate secure random string
    public func secureRandomString(length: Int) throws -> String {
        let data = try secureRandomData(count: length)
        return data.base64EncodedString()
            .prefix(length)
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
            .trimmingCharacters(in: CharacterSet(charactersIn: "="))
    }
}

// MARK: - Crypto Error

public enum CryptoError: LocalizedError {
    case keyNotInitialized
    case encryptionFailed
    case decryptionFailed
    case encodingFailed
    case decodingFailed
    case keyGenerationFailed
    case randomGenerationFailed

    public var errorDescription: String? {
        switch self {
        case .keyNotInitialized:
            return "Encryption key not initialized"
        case .encryptionFailed:
            return "Failed to encrypt data"
        case .decryptionFailed:
            return "Failed to decrypt data"
        case .encodingFailed:
            return "Failed to encode data"
        case .decodingFailed:
            return "Failed to decode data"
        case .keyGenerationFailed:
            return "Failed to generate encryption key"
        case .randomGenerationFailed:
            return "Failed to generate secure random data"
        }
    }
}
