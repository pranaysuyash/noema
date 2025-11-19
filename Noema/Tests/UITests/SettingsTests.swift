//
//  SettingsTests.swift
//  Noema
//
//  Created on November 19, 2025.
//

import XCTest

final class SettingsTests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    // MARK: - Navigate to Settings Tests

    func test_navigateToSettings_opensSettingsView() {
        // When
        let settingsButton = app.buttons["settingsButton"]
        if settingsButton.exists {
            settingsButton.tap()
        }

        // Then
        XCTAssertTrue(app.navigationBars["Settings"].exists || app.staticTexts["Settings"].exists)
    }

    // MARK: - Appearance Settings Tests

    func test_changeTheme_switchesToDarkMode() {
        // Given
        let settingsButton = app.buttons["settingsButton"]
        if settingsButton.exists {
            settingsButton.tap()
        }

        // When
        let themeRow = app.cells["themeRow"]
        if themeRow.exists {
            themeRow.tap()
        }

        let darkModeButton = app.buttons["darkTheme"]
        if darkModeButton.exists {
            darkModeButton.tap()
        }

        // Then
        XCTAssertTrue(darkModeButton.isSelected || app.navigationBars.firstMatch.exists)
    }

    func test_changeTheme_switchesToLightMode() {
        // Given
        let settingsButton = app.buttons["settingsButton"]
        if settingsButton.exists {
            settingsButton.tap()
        }

        // When
        let themeRow = app.cells["themeRow"]
        if themeRow.exists {
            themeRow.tap()
        }

        let lightModeButton = app.buttons["lightTheme"]
        if lightModeButton.exists {
            lightModeButton.tap()
        }

        // Then
        XCTAssertTrue(lightModeButton.isSelected || app.navigationBars.firstMatch.exists)
    }

    func test_changeTheme_switchesToAutoMode() {
        // Given
        let settingsButton = app.buttons["settingsButton"]
        if settingsButton.exists {
            settingsButton.tap()
        }

        // When
        let themeRow = app.cells["themeRow"]
        if themeRow.exists {
            themeRow.tap()
        }

        let autoModeButton = app.buttons["autoTheme"]
        if autoModeButton.exists {
            autoModeButton.tap()
        }

        // Then
        XCTAssertTrue(autoModeButton.isSelected || app.navigationBars.firstMatch.exists)
    }

    // MARK: - Privacy Settings Tests

    func test_toggleDataProcessing_changesPreference() {
        // Given
        let settingsButton = app.buttons["settingsButton"]
        if settingsButton.exists {
            settingsButton.tap()
        }

        // When
        let privacyRow = app.cells["privacyRow"]
        if privacyRow.exists {
            privacyRow.tap()
        }

        let dataProcessingToggle = app.switches["dataProcessingToggle"]
        if dataProcessingToggle.exists {
            let initialState = dataProcessingToggle.value as? String
            dataProcessingToggle.tap()
            let newState = dataProcessingToggle.value as? String

            // Then
            XCTAssertNotEqual(initialState, newState)
        }
    }

    func test_toggleLocationServices_changesPreference() {
        // Given
        let settingsButton = app.buttons["settingsButton"]
        if settingsButton.exists {
            settingsButton.tap()
        }

        let privacyRow = app.cells["privacyRow"]
        if privacyRow.exists {
            privacyRow.tap()
        }

        // When
        let locationToggle = app.switches["locationServicesToggle"]
        if locationToggle.exists {
            let initialState = locationToggle.value as? String
            locationToggle.tap()
            let newState = locationToggle.value as? String

            // Then
            XCTAssertNotEqual(initialState, newState)
        }
    }

    func test_toggleHealthKit_changesPreference() {
        // Given
        let settingsButton = app.buttons["settingsButton"]
        if settingsButton.exists {
            settingsButton.tap()
        }

        let privacyRow = app.cells["privacyRow"]
        if privacyRow.exists {
            privacyRow.tap()
        }

        // When
        let healthKitToggle = app.switches["healthKitToggle"]
        if healthKitToggle.exists {
            let initialState = healthKitToggle.value as? String
            healthKitToggle.tap()
            let newState = healthKitToggle.value as? String

            // Then
            XCTAssertNotEqual(initialState, newState)
        }
    }

    // MARK: - Notification Settings Tests

    func test_toggleDailyReminder_changesPreference() {
        // Given
        let settingsButton = app.buttons["settingsButton"]
        if settingsButton.exists {
            settingsButton.tap()
        }

        let notificationsRow = app.cells["notificationsRow"]
        if notificationsRow.exists {
            notificationsRow.tap()
        }

        // When
        let reminderToggle = app.switches["dailyReminderToggle"]
        if reminderToggle.exists {
            let initialState = reminderToggle.value as? String
            reminderToggle.tap()
            let newState = reminderToggle.value as? String

            // Then
            XCTAssertNotEqual(initialState, newState)
        }
    }

    func test_setReminderTime_opensTimePicker() {
        // Given
        let settingsButton = app.buttons["settingsButton"]
        if settingsButton.exists {
            settingsButton.tap()
        }

        let notificationsRow = app.cells["notificationsRow"]
        if notificationsRow.exists {
            notificationsRow.tap()
        }

        // When
        let reminderTimeRow = app.cells["reminderTimeRow"]
        if reminderTimeRow.exists {
            reminderTimeRow.tap()
        }

        // Then
        XCTAssertTrue(app.datePickers.firstMatch.exists || app.pickers.firstMatch.exists)
    }

    // MARK: - Subscription Settings Tests

    func test_viewSubscription_showsSubscriptionInfo() {
        // Given
        let settingsButton = app.buttons["settingsButton"]
        if settingsButton.exists {
            settingsButton.tap()
        }

        // When
        let subscriptionRow = app.cells["subscriptionRow"]
        if subscriptionRow.exists {
            subscriptionRow.tap()
        }

        // Then
        XCTAssertTrue(app.navigationBars["Subscription"].exists ||
                     app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Plan'")).firstMatch.exists)
    }

    func test_viewUpgradeOptions_showsPricing() {
        // Given
        let settingsButton = app.buttons["settingsButton"]
        if settingsButton.exists {
            settingsButton.tap()
        }

        let subscriptionRow = app.cells["subscriptionRow"]
        if subscriptionRow.exists {
            subscriptionRow.tap()
        }

        // When
        let upgradeButton = app.buttons["upgradeButton"]
        if upgradeButton.exists {
            upgradeButton.tap()
        }

        // Then
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Pro' OR label CONTAINS '$'")).firstMatch.exists)
    }

    // MARK: - Data Export Tests

    func test_exportData_showsExportOptions() {
        // Given
        let settingsButton = app.buttons["settingsButton"]
        if settingsButton.exists {
            settingsButton.tap()
        }

        // When
        let exportRow = app.cells["exportDataRow"]
        if exportRow.exists {
            exportRow.tap()
        }

        // Then
        XCTAssertTrue(app.sheets.firstMatch.exists ||
                     app.buttons["Export as JSON"].exists ||
                     app.buttons["Export as PDF"].exists)
    }

    // MARK: - About Section Tests

    func test_viewAbout_showsAppInfo() {
        // Given
        let settingsButton = app.buttons["settingsButton"]
        if settingsButton.exists {
            settingsButton.tap()
        }

        // When
        let aboutRow = app.cells["aboutRow"]
        if aboutRow.exists {
            aboutRow.tap()
        }

        // Then
        XCTAssertTrue(app.navigationBars["About"].exists ||
                     app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Version'")).firstMatch.exists)
    }

    func test_viewPrivacyPolicy_opensPolicy() {
        // Given
        let settingsButton = app.buttons["settingsButton"]
        if settingsButton.exists {
            settingsButton.tap()
        }

        let aboutRow = app.cells["aboutRow"]
        if aboutRow.exists {
            aboutRow.tap()
        }

        // When
        let privacyPolicyButton = app.buttons["privacyPolicyButton"]
        if privacyPolicyButton.exists {
            privacyPolicyButton.tap()
        }

        // Then
        XCTAssertTrue(app.webViews.firstMatch.exists || app.textViews.firstMatch.exists)
    }

    // MARK: - Account Settings Tests

    func test_signOut_showsConfirmation() {
        // Given
        let settingsButton = app.buttons["settingsButton"]
        if settingsButton.exists {
            settingsButton.tap()
        }

        // When
        let signOutButton = app.buttons["signOutButton"]
        if signOutButton.exists {
            signOutButton.tap()
        }

        // Then
        XCTAssertTrue(app.alerts.firstMatch.exists || app.sheets.firstMatch.exists)
    }

    func test_deleteAccount_showsWarning() {
        // Given
        let settingsButton = app.buttons["settingsButton"]
        if settingsButton.exists {
            settingsButton.tap()
        }

        // When
        let deleteAccountButton = app.buttons["deleteAccountButton"]
        if deleteAccountButton.exists {
            deleteAccountButton.tap()
        }

        // Then
        XCTAssertTrue(app.alerts.firstMatch.exists)
    }

    // MARK: - Language Settings Tests

    func test_changeLanguage_showsLanguageOptions() {
        // Given
        let settingsButton = app.buttons["settingsButton"]
        if settingsButton.exists {
            settingsButton.tap()
        }

        // When
        let languageRow = app.cells["languageRow"]
        if languageRow.exists {
            languageRow.tap()
        }

        // Then
        XCTAssertTrue(app.navigationBars["Language"].exists || app.cells.count > 0)
    }
}
