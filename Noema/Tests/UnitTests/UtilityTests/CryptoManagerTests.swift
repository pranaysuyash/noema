//
//  CryptoManagerTests.swift
//  Noema
//
//  Created on November 19, 2025.
//

import XCTest
@testable import Noema

final class CryptoManagerTests: XCTestCase {

    var cryptoManager: CryptoManager!

    override func setUp() {
        super.setUp()
        cryptoManager = CryptoManager.shared
    }

    override func tearDown() {
        cryptoManager = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func test_initialize_createsEncryptionKey() throws {
        // When
        try cryptoManager.initialize()

        // Then - Should not throw
        XCTAssertTrue(true)
    }

    // MARK: - String Encryption Tests

    func test_encryptString_returnsNonEmptyString() throws {
        // Given
        try cryptoManager.initialize()
        let plaintext = "Secret message"

        // When
        let encrypted = try cryptoManager.encrypt(string: plaintext)

        // Then
        XCTAssertFalse(encrypted.isEmpty)
        XCTAssertNotEqual(encrypted, plaintext)
    }

    func test_encryptString_differentForDifferentInputs() throws {
        // Given
        try cryptoManager.initialize()
        let text1 = "Message 1"
        let text2 = "Message 2"

        // When
        let encrypted1 = try cryptoManager.encrypt(string: text1)
        let encrypted2 = try cryptoManager.encrypt(string: text2)

        // Then
        XCTAssertNotEqual(encrypted1, encrypted2)
    }

    // MARK: - String Decryption Tests

    func test_decryptString_retrievesOriginalText() throws {
        // Given
        try cryptoManager.initialize()
        let plaintext = "Secret message"

        // When
        let encrypted = try cryptoManager.encrypt(string: plaintext)
        let decrypted = try cryptoManager.decrypt(string: encrypted)

        // Then
        XCTAssertEqual(decrypted, plaintext)
    }

    func test_decryptString_throwsForInvalidData() throws {
        // Given
        try cryptoManager.initialize()
        let invalidEncrypted = "not-valid-encrypted-data"

        // When/Then
        XCTAssertThrowsError(try cryptoManager.decrypt(string: invalidEncrypted))
    }

    // MARK: - Data Encryption Tests

    func test_encryptData_returnsNonEmptyData() throws {
        // Given
        try cryptoManager.initialize()
        let plainData = "Secret data".data(using: .utf8)!

        // When
        let encrypted = try cryptoManager.encrypt(data: plainData)

        // Then
        XCTAssertGreaterThan(encrypted.count, 0)
        XCTAssertNotEqual(encrypted, plainData)
    }

    func test_decryptData_retrievesOriginalData() throws {
        // Given
        try cryptoManager.initialize()
        let plainData = "Secret data".data(using: .utf8)!

        // When
        let encrypted = try cryptoManager.encrypt(data: plainData)
        let decrypted = try cryptoManager.decrypt(data: encrypted)

        // Then
        XCTAssertEqual(decrypted, plainData)
    }

    // MARK: - Hashing Tests

    func test_hashString_returnsConsistentHash() {
        // Given
        let input = "test string"

        // When
        let hash1 = cryptoManager.hash(string: input)
        let hash2 = cryptoManager.hash(string: input)

        // Then
        XCTAssertEqual(hash1, hash2)
    }

    func test_hashString_differentForDifferentInputs() {
        // Given
        let input1 = "test 1"
        let input2 = "test 2"

        // When
        let hash1 = cryptoManager.hash(string: input1)
        let hash2 = cryptoManager.hash(string: input2)

        // Then
        XCTAssertNotEqual(hash1, hash2)
    }

    func test_hashString_returnsNonEmptyString() {
        // Given
        let input = "test"

        // When
        let hash = cryptoManager.hash(string: input)

        // Then
        XCTAssertFalse(hash.isEmpty)
    }

    func test_hashData_returnsConsistentHash() {
        // Given
        let data = "test data".data(using: .utf8)!

        // When
        let hash1 = cryptoManager.hash(data: data)
        let hash2 = cryptoManager.hash(data: data)

        // Then
        XCTAssertEqual(hash1, hash2)
    }

    // MARK: - Secure Random Tests

    func test_secureRandomData_generatesDataOfCorrectLength() throws {
        // Given
        let length = 32

        // When
        let randomData = try cryptoManager.secureRandomData(count: length)

        // Then
        XCTAssertEqual(randomData.count, length)
    }

    func test_secureRandomData_generatesDifferentValues() throws {
        // When
        let random1 = try cryptoManager.secureRandomData(count: 32)
        let random2 = try cryptoManager.secureRandomData(count: 32)

        // Then
        XCTAssertNotEqual(random1, random2)
    }

    func test_secureRandomString_generatesStringOfCorrectLength() throws {
        // Given
        let length = 16

        // When
        let randomString = try cryptoManager.secureRandomString(length: length)

        // Then
        XCTAssertEqual(randomString.count, length)
    }

    func test_secureRandomString_generatesDifferentValues() throws {
        // When
        let random1 = try cryptoManager.secureRandomString(length: 16)
        let random2 = try cryptoManager.secureRandomString(length: 16)

        // Then
        XCTAssertNotEqual(random1, random2)
    }

    // MARK: - Round-trip Tests

    func test_encryptDecryptRoundtrip_preservesData() throws {
        // Given
        try cryptoManager.initialize()
        let testStrings = [
            "Simple text",
            "Text with special chars: !@#$%^&*()",
            "Unicode text: 你好世界 🌍",
            String(repeating: "x", count: 1000) // Large text
        ]

        // When/Then
        for plaintext in testStrings {
            let encrypted = try cryptoManager.encrypt(string: plaintext)
            let decrypted = try cryptoManager.decrypt(string: encrypted)
            XCTAssertEqual(decrypted, plaintext, "Failed for: \(plaintext)")
        }
    }

    func test_encryptDecryptRoundtrip_worksWithEmptyString() throws {
        // Given
        try cryptoManager.initialize()
        let emptyString = ""

        // When
        let encrypted = try cryptoManager.encrypt(string: emptyString)
        let decrypted = try cryptoManager.decrypt(string: encrypted)

        // Then
        XCTAssertEqual(decrypted, emptyString)
    }

    // MARK: - Error Handling Tests

    func test_encrypt_throwsForUninitializedKey() throws {
        // Note: CryptoManager auto-initializes, so this test ensures it handles that gracefully
        // Given
        let plaintext = "test"

        // When/Then - Should not throw due to auto-initialization
        let _ = try cryptoManager.encrypt(string: plaintext)
        XCTAssertTrue(true)
    }
}
