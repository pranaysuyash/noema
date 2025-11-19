//
//  DateExtensionsTests.swift
//  Noema
//
//  Created on November 19, 2025.
//

import XCTest
@testable import Noema

final class DateExtensionsTests: XCTestCase {

    let calendar = Calendar.current

    // MARK: - Is Today Tests

    func test_isToday_returnsTrueForToday() {
        // Given
        let today = Date()

        // When
        let result = today.isToday

        // Then
        XCTAssertTrue(result)
    }

    func test_isToday_returnsFalseForYesterday() {
        // Given
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!

        // When
        let result = yesterday.isToday

        // Then
        XCTAssertFalse(result)
    }

    // MARK: - Is Yesterday Tests

    func test_isYesterday_returnsTrueForYesterday() {
        // Given
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!

        // When
        let result = yesterday.isYesterday

        // Then
        XCTAssertTrue(result)
    }

    func test_isYesterday_returnsFalseForToday() {
        // Given
        let today = Date()

        // When
        let result = today.isYesterday

        // Then
        XCTAssertFalse(result)
    }

    // MARK: - Is This Week Tests

    func test_isThisWeek_returnsTrueForThisWeek() {
        // Given
        let thisWeek = Date()

        // When
        let result = thisWeek.isThisWeek

        // Then
        XCTAssertTrue(result)
    }

    func test_isThisWeek_returnsFalseForNextWeek() {
        // Given
        let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: Date())!

        // When
        let result = nextWeek.isThisWeek

        // Then
        XCTAssertFalse(result)
    }

    // MARK: - Is This Month Tests

    func test_isThisMonth_returnsTrueForThisMonth() {
        // Given
        let thisMonth = Date()

        // When
        let result = thisMonth.isThisMonth

        // Then
        XCTAssertTrue(result)
    }

    func test_isThisMonth_returnsFalseForNextMonth() {
        // Given
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: Date())!

        // When
        let result = nextMonth.isThisMonth

        // Then
        XCTAssertFalse(result)
    }

    // MARK: - Relative Time String Tests

    func test_relativeTimeString_returnsNonEmptyString() {
        // Given
        let pastDate = calendar.date(byAdding: .hour, value: -2, to: Date())!

        // When
        let result = pastDate.relativeTimeString

        // Then
        XCTAssertFalse(result.isEmpty)
    }

    func test_shortRelativeTime_returnsAbbreviatedString() {
        // Given
        let pastDate = calendar.date(byAdding: .hour, value: -2, to: Date())!

        // When
        let result = pastDate.shortRelativeTime

        // Then
        XCTAssertFalse(result.isEmpty)
    }

    // MARK: - Smart Formatted Tests

    func test_smartFormatted_includesTimeForToday() {
        // Given
        let today = Date()

        // When
        let result = today.smartFormatted

        // Then
        XCTAssertTrue(result.contains("Today"))
    }

    func test_smartFormatted_includesYesterdayText() {
        // Given
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!

        // When
        let result = yesterday.smartFormatted

        // Then
        XCTAssertTrue(result.contains("Yesterday"))
    }

    // MARK: - Start/End of Day Tests

    func test_startOfDay_setsTimeToMidnight() {
        // Given
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = 14
        components.minute = 30
        let afternoon = calendar.date(from: components)!

        // When
        let startOfDay = afternoon.startOfDay

        // Then
        let startComponents = calendar.dateComponents([.hour, .minute, .second], from: startOfDay)
        XCTAssertEqual(startComponents.hour, 0)
        XCTAssertEqual(startComponents.minute, 0)
        XCTAssertEqual(startComponents.second, 0)
    }

    func test_endOfDay_setsTimeToLastSecond() {
        // Given
        let date = Date()

        // When
        let endOfDay = date.endOfDay

        // Then
        let components = calendar.dateComponents([.hour, .minute, .second], from: endOfDay)
        XCTAssertEqual(components.hour, 23)
        XCTAssertEqual(components.minute, 59)
        XCTAssertEqual(components.second, 59)
    }

    // MARK: - Start of Week Tests

    func test_startOfWeek_returnsBeginningOfWeek() {
        // Given
        let date = Date()

        // When
        let startOfWeek = date.startOfWeek

        // Then
        let weekday = calendar.component(.weekday, from: startOfWeek)
        XCTAssertEqual(weekday, calendar.firstWeekday)
    }

    // MARK: - Start of Month Tests

    func test_startOfMonth_returnsFirstDayOfMonth() {
        // Given
        let date = Date()

        // When
        let startOfMonth = date.startOfMonth

        // Then
        let day = calendar.component(.day, from: startOfMonth)
        XCTAssertEqual(day, 1)
    }

    // MARK: - Adding Days Tests

    func test_addingDays_addsCorrectNumberOfDays() {
        // Given
        let date = Date()

        // When
        let futureDate = date.adding(days: 5)

        // Then
        let daysBetween = calendar.dateComponents([.day], from: date, to: futureDate).day
        XCTAssertEqual(daysBetween, 5)
    }

    func test_addingDays_handlesNegativeValues() {
        // Given
        let date = Date()

        // When
        let pastDate = date.adding(days: -3)

        // Then
        let daysBetween = calendar.dateComponents([.day], from: pastDate, to: date).day
        XCTAssertEqual(daysBetween, 3)
    }

    // MARK: - Adding Months Tests

    func test_addingMonths_addsCorrectNumberOfMonths() {
        // Given
        let date = Date()

        // When
        let futureDate = date.adding(months: 2)

        // Then
        let monthsBetween = calendar.dateComponents([.month], from: date, to: futureDate).month
        XCTAssertEqual(monthsBetween, 2)
    }

    // MARK: - Days Between Tests

    func test_daysBetween_calculatesCorrectly() {
        // Given
        let date1 = Date()
        let date2 = calendar.date(byAdding: .day, value: 7, to: date1)!

        // When
        let daysBetween = date1.daysBetween(date2)

        // Then
        XCTAssertEqual(daysBetween, 7)
    }

    func test_daysBetween_returnsAbsoluteValue() {
        // Given
        let date1 = Date()
        let date2 = calendar.date(byAdding: .day, value: -5, to: date1)!

        // When
        let daysBetween = date1.daysBetween(date2)

        // Then
        XCTAssertEqual(daysBetween, 5)
    }

    func test_daysBetween_returnsZeroForSameDay() {
        // Given
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = 10
        let morning = calendar.date(from: components)!

        components.hour = 18
        let evening = calendar.date(from: components)!

        // When
        let daysBetween = morning.daysBetween(evening)

        // Then
        XCTAssertEqual(daysBetween, 0)
    }
}
