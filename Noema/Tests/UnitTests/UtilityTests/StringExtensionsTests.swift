//
//  StringExtensionsTests.swift
//  Noema
//
//  Created on November 19, 2025.
//

import XCTest
@testable import Noema

final class StringExtensionsTests: XCTestCase {

    // MARK: - Trimmed Tests

    func test_trimmed_removesWhitespace() {
        // Given
        let string = "  hello world  "

        // When
        let result = string.trimmed

        // Then
        XCTAssertEqual(result, "hello world")
    }

    func test_trimmed_removesNewlines() {
        // Given
        let string = "\nhello\n"

        // When
        let result = string.trimmed

        // Then
        XCTAssertEqual(result, "hello")
    }

    // MARK: - Is Blank Tests

    func test_isBlank_returnsTrueForEmptyString() {
        // Given
        let string = ""

        // When
        let result = string.isBlank

        // Then
        XCTAssertTrue(result)
    }

    func test_isBlank_returnsTrueForWhitespaceOnly() {
        // Given
        let string = "   "

        // When
        let result = string.isBlank

        // Then
        XCTAssertTrue(result)
    }

    func test_isBlank_returnsFalseForNonEmptyString() {
        // Given
        let string = "hello"

        // When
        let result = string.isBlank

        // Then
        XCTAssertFalse(result)
    }

    // MARK: - Word Count Tests

    func test_wordCount_countsWordsCorrectly() {
        // Given
        let string = "This is a test string"

        // When
        let count = string.wordCount

        // Then
        XCTAssertEqual(count, 5)
    }

    func test_wordCount_handlesMultipleSpaces() {
        // Given
        let string = "hello    world"

        // When
        let count = string.wordCount

        // Then
        XCTAssertEqual(count, 2)
    }

    func test_wordCount_returnsZeroForEmptyString() {
        // Given
        let string = ""

        // When
        let count = string.wordCount

        // Then
        XCTAssertEqual(count, 0)
    }

    // MARK: - Character Count Excluding Spaces Tests

    func test_characterCountExcludingSpaces_countsCorrectly() {
        // Given
        let string = "hello world"

        // When
        let count = string.characterCountExcludingSpaces

        // Then
        XCTAssertEqual(count, 10) // "helloworld" = 10 chars
    }

    // MARK: - Truncated Tests

    func test_truncated_truncatesLongString() {
        // Given
        let string = "This is a very long string"

        // When
        let result = string.truncated(to: 10)

        // Then
        XCTAssertEqual(result, "This is a ...")
    }

    func test_truncated_doesNotTruncateShortString() {
        // Given
        let string = "Short"

        // When
        let result = string.truncated(to: 10)

        // Then
        XCTAssertEqual(result, "Short")
    }

    func test_truncated_usesCustomTrailing() {
        // Given
        let string = "This is a very long string"

        // When
        let result = string.truncated(to: 10, trailing: "…")

        // Then
        XCTAssertEqual(result, "This is a …")
    }

    // MARK: - First Sentence Tests

    func test_firstSentence_extractsFirstSentence() {
        // Given
        let string = "First sentence. Second sentence. Third sentence."

        // When
        let result = string.firstSentence

        // Then
        XCTAssertEqual(result, "First sentence")
    }

    func test_firstSentence_returnsFullStringIfNoSeparator() {
        // Given
        let string = "Single sentence without period"

        // When
        let result = string.firstSentence

        // Then
        XCTAssertEqual(result, string)
    }

    // MARK: - First Words Tests

    func test_firstWords_extractsCorrectNumberOfWords() {
        // Given
        let string = "one two three four five"

        // When
        let result = string.firstWords(3)

        // Then
        XCTAssertEqual(result, "one two three")
    }

    func test_firstWords_returnsAllIfLessThanCount() {
        // Given
        let string = "one two"

        // When
        let result = string.firstWords(5)

        // Then
        XCTAssertEqual(result, "one two")
    }

    // MARK: - Capitalized First Tests

    func test_capitalizedFirst_capitalizesFirstLetter() {
        // Given
        let string = "hello world"

        // When
        let result = string.capitalizedFirst

        // Then
        XCTAssertEqual(result, "Hello world")
    }

    func test_capitalizedFirst_handlesEmptyString() {
        // Given
        let string = ""

        // When
        let result = string.capitalizedFirst

        // Then
        XCTAssertEqual(result, "")
    }

    // MARK: - Contains Any Tests

    func test_containsAny_returnsTrueWhenContains() {
        // Given
        let string = "Hello world"

        // When
        let result = string.containsAny(of: ["world", "foo", "bar"])

        // Then
        XCTAssertTrue(result)
    }

    func test_containsAny_returnsFalseWhenNotContains() {
        // Given
        let string = "Hello world"

        // When
        let result = string.containsAny(of: ["foo", "bar"])

        // Then
        XCTAssertFalse(result)
    }

    func test_containsAny_caseInsensitive() {
        // Given
        let string = "Hello world"

        // When
        let result = string.containsAny(of: ["WORLD"], caseSensitive: false)

        // Then
        XCTAssertTrue(result)
    }

    // MARK: - Mentions Tests

    func test_mentions_extractsMentions() {
        // Given
        let string = "Hello @alice and @bob!"

        // When
        let mentions = string.mentions

        // Then
        XCTAssertEqual(mentions.count, 2)
        XCTAssertTrue(mentions.contains("@alice"))
        XCTAssertTrue(mentions.contains("@bob"))
    }

    func test_mentions_returnsEmptyForNoMentions() {
        // Given
        let string = "No mentions here"

        // When
        let mentions = string.mentions

        // Then
        XCTAssertEqual(mentions.count, 0)
    }

    // MARK: - Hashtags Tests

    func test_hashtags_extractsHashtags() {
        // Given
        let string = "Great day #sunny #happy"

        // When
        let hashtags = string.hashtags

        // Then
        XCTAssertEqual(hashtags.count, 2)
        XCTAssertTrue(hashtags.contains("#sunny"))
        XCTAssertTrue(hashtags.contains("#happy"))
    }

    func test_hashtags_returnsEmptyForNoHashtags() {
        // Given
        let string = "No hashtags here"

        // When
        let hashtags = string.hashtags

        // Then
        XCTAssertEqual(hashtags.count, 0)
    }

    // MARK: - Plain Text Tests

    func test_plainText_removesMarkdown() {
        // Given
        let string = "This is **bold** and *italic* text"

        // When
        let result = string.plainText

        // Then
        XCTAssertEqual(result, "This is bold and italic text")
    }

    func test_plainText_removesUnderscores() {
        // Given
        let string = "This is __bold__ and _italic_"

        // When
        let result = string.plainText

        // Then
        XCTAssertEqual(result, "This is bold and italic")
    }
}
