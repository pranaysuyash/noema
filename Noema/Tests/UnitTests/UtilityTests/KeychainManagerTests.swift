//
//  KeychainManagerTests.swift
//  Noema
//
//  Created on November 19, 2025.
//

import XCTest
@testable import Noema

final class KeychainManagerTests: XCTestCase {

    var keychainManager: KeychainManager!
    let testKey = "com.noema.test.key"

    override func setUp() {
        super.setUp()
        keychainManager = KeychainManager.shared
        // Clean up any existing test data
        try? keychainManager.delete(key: testKey)
    }

    override func tearDown() {
        // Clean up test data
        try? keychainManager.delete(key: testKey)
        keychainManager = nil
        super.tearDown()
    }

    // MARK: - Save and Retrieve Data Tests

    func test_saveData_storesDataSuccessfully() throws {
        // Given
        let testData = "test data".data(using: .utf8)!

        // When
        try keychainManager.save(key: testKey, data: testData)

        // Then - Should not throw
        XCTAssertTrue(true)
    }

    func test_retrieveData_returnsStoredData() throws {
        // Given
        let testData = "test data".data(using: .utf8)!
        try keychainManager.save(key: testKey, data: testData)

        // When
        let retrieved = try keychainManager.retrieve(key: testKey)

        // Then
        XCTAssertEqual(retrieved, testData)
    }

    func test_retrieveData_throwsForNonexistentKey() throws {
        // Given
        let nonexistentKey = "com.noema.nonexistent"

        // When/Then
        XCTAssertThrowsError(try keychainManager.retrieve(key: nonexistentKey))
    }

    // MARK: - Save and Retrieve String Tests

    func test_saveString_storesStringSuccessfully() throws {
        // Given
        let testString = "Secret password"

        // When
        try keychainManager.save(key: testKey, string: testString)

        // Then - Should not throw
        XCTAssertTrue(true)
    }

    func test_retrieveString_returnsStoredString() throws {
        // Given
        let testString = "Secret password"
        try keychainManager.save(key: testKey, string: testString)

        // When
        let retrieved = try keychainManager.retrieveString(key: testKey)

        // Then
        XCTAssertEqual(retrieved, testString)
    }

    func test_retrieveString_throwsForNonexistentKey() throws {
        // Given
        let nonexistentKey = "com.noema.nonexistent"

        // When/Then
        XCTAssertThrowsError(try keychainManager.retrieveString(key: nonexistentKey))
    }

    // MARK: - Update Tests

    func test_save_updatesExistingValue() throws {
        // Given
        let initialValue = "initial"
        let updatedValue = "updated"
        try keychainManager.save(key: testKey, string: initialValue)

        // When
        try keychainManager.save(key: testKey, string: updatedValue)

        // Then
        let retrieved = try keychainManager.retrieveString(key: testKey)
        XCTAssertEqual(retrieved, updatedValue)
    }

    // MARK: - Delete Tests

    func test_delete_removesStoredData() throws {
        // Given
        let testData = "test data".data(using: .utf8)!
        try keychainManager.save(key: testKey, data: testData)

        // When
        try keychainManager.delete(key: testKey)

        // Then
        XCTAssertThrowsError(try keychainManager.retrieve(key: testKey))
    }

    func test_delete_doesNotThrowForNonexistentKey() throws {
        // Given
        let nonexistentKey = "com.noema.nonexistent"

        // When/Then - Should not throw
        try keychainManager.delete(key: nonexistentKey)
        XCTAssertTrue(true)
    }

    // MARK: - Exists Tests

    func test_exists_returnsTrueForExistingKey() throws {
        // Given
        let testData = "test".data(using: .utf8)!
        try keychainManager.save(key: testKey, data: testData)

        // When
        let exists = keychainManager.exists(key: testKey)

        // Then
        XCTAssertTrue(exists)
    }

    func test_exists_returnsFalseForNonexistentKey() {
        // Given
        let nonexistentKey = "com.noema.nonexistent"

        // When
        let exists = keychainManager.exists(key: nonexistentKey)

        // Then
        XCTAssertFalse(exists)
    }

    // MARK: - Encryption Key Tests

    func test_getOrCreateEncryptionKey_createsKey() throws {
        // When
        let key = try keychainManager.getOrCreateEncryptionKey()

        // Then
        XCTAssertEqual(key.count, 32) // AES-256 requires 32 bytes
    }

    func test_getOrCreateEncryptionKey_returnsExistingKey() throws {
        // Given
        let key1 = try keychainManager.getOrCreateEncryptionKey()

        // When
        let key2 = try keychainManager.getOrCreateEncryptionKey()

        // Then
        XCTAssertEqual(key1, key2)
    }

    // MARK: - Special Characters Tests

    func test_saveRetrieve_handlesSpecialCharacters() throws {
        // Given
        let specialString = "!@#$%^&*()_+-=[]{}|;:'\",.<>?/~`"
        try keychainManager.save(key: testKey, string: specialString)

        // When
        let retrieved = try keychainManager.retrieveString(key: testKey)

        // Then
        XCTAssertEqual(retrieved, specialString)
    }

    func test_saveRetrieve_handlesUnicode() throws {
        // Given
        let unicodeString = "Hello 你好 مرحبا 🌍"
        try keychainManager.save(key: testKey, string: unicodeString)

        // When
        let retrieved = try keychainManager.retrieveString(key: testKey)

        // Then
        XCTAssertEqual(retrieved, unicodeString)
    }

    // MARK: - Large Data Tests

    func test_saveRetrieve_handlesLargeData() throws {
        // Given
        let largeString = String(repeating: "x", count: 10000)
        try keychainManager.save(key: testKey, string: largeString)

        // When
        let retrieved = try keychainManager.retrieveString(key: testKey)

        // Then
        XCTAssertEqual(retrieved, largeString)
    }

    // MARK: - Multiple Keys Tests

    func test_saveRetrieve_handlesMultipleKeys() throws {
        // Given
        let key1 = "com.noema.test.key1"
        let key2 = "com.noema.test.key2"
        let value1 = "value1"
        let value2 = "value2"

        // When
        try keychainManager.save(key: key1, string: value1)
        try keychainManager.save(key: key2, string: value2)

        // Then
        let retrieved1 = try keychainManager.retrieveString(key: key1)
        let retrieved2 = try keychainManager.retrieveString(key: key2)

        XCTAssertEqual(retrieved1, value1)
        XCTAssertEqual(retrieved2, value2)

        // Cleanup
        try? keychainManager.delete(key: key1)
        try? keychainManager.delete(key: key2)
    }

    // MARK: - Empty String Tests

    func test_saveRetrieve_handlesEmptyString() throws {
        // Given
        let emptyString = ""

        // When
        try keychainManager.save(key: testKey, string: emptyString)
        let retrieved = try keychainManager.retrieveString(key: testKey)

        // Then
        XCTAssertEqual(retrieved, emptyString)
    }
}
