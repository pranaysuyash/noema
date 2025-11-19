//
//  LocationTests.swift
//  Noema
//
//  Created on November 19, 2025.
//

import XCTest
import CoreData
import CoreLocation
@testable import Noema

final class LocationTests: XCTestCase {

    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
    }

    override func tearDown() {
        context = nil
        persistenceController = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func test_locationInitialization_setsDefaultValues() {
        // Given/When
        let location = Location(context: context)

        // Then
        XCTAssertNotNil(location.id)
        XCTAssertEqual(location.latitude, 0)
        XCTAssertEqual(location.longitude, 0)
        XCTAssertEqual(location.altitude, 0)
        XCTAssertEqual(location.averageValence, 0)
        XCTAssertEqual(location.averageEnergy, 0)
        XCTAssertEqual(location.visitCount, 0)
        XCTAssertNotNil(location.firstVisit)
        XCTAssertNotNil(location.lastVisit)
        XCTAssertFalse(location.isPrivate)
    }

    // MARK: - Coordinate Tests

    func test_coordinate_returnsCorrectCLLocationCoordinate2D() {
        // Given
        let location = Location(context: context)
        location.latitude = 37.7749
        location.longitude = -122.4194

        // When
        let coordinate = location.coordinate

        // Then
        XCTAssertEqual(coordinate.latitude, 37.7749, accuracy: 0.0001)
        XCTAssertEqual(coordinate.longitude, -122.4194, accuracy: 0.0001)
    }

    func test_clLocation_returnsValidCLLocation() {
        // Given
        let location = Location(context: context)
        location.latitude = 37.7749
        location.longitude = -122.4194
        location.altitude = 100

        // When
        let clLocation = location.clLocation

        // Then
        XCTAssertEqual(clLocation.coordinate.latitude, 37.7749, accuracy: 0.0001)
        XCTAssertEqual(clLocation.coordinate.longitude, -122.4194, accuracy: 0.0001)
        XCTAssertEqual(clLocation.altitude, 100, accuracy: 0.1)
    }

    // MARK: - Display Name Tests

    func test_displayName_usesCustomLabelWhenSet() {
        // Given
        let location = Location(context: context)
        location.customLabel = "My Favorite Spot"
        location.placeName = "Starbucks"

        // When
        let displayName = location.displayName

        // Then
        XCTAssertEqual(displayName, "My Favorite Spot")
    }

    func test_displayName_usesPlaceNameWhenNoCustomLabel() {
        // Given
        let location = Location(context: context)
        location.placeName = "Central Park"
        location.city = "New York"

        // When
        let displayName = location.displayName

        // Then
        XCTAssertEqual(displayName, "Central Park")
    }

    func test_displayName_usesCityWhenNoPlaceName() {
        // Given
        let location = Location(context: context)
        location.city = "San Francisco"

        // When
        let displayName = location.displayName

        // Then
        XCTAssertEqual(displayName, "San Francisco")
    }

    func test_displayName_usesDefaultWhenNoInfo() {
        // Given
        let location = Location(context: context)

        // When
        let displayName = location.displayName

        // Then
        XCTAssertEqual(displayName, "Unknown Location")
    }

    // MARK: - Full Address Tests

    func test_fullAddress_combinesAllComponents() {
        // Given
        let location = Location(context: context)
        location.placeName = "Coffee Shop"
        location.city = "San Francisco"
        location.state = "CA"
        location.country = "USA"

        // When
        let address = location.fullAddress

        // Then
        XCTAssertEqual(address, "Coffee Shop, San Francisco, CA, USA")
    }

    func test_fullAddress_handlesPartialComponents() {
        // Given
        let location = Location(context: context)
        location.city = "San Francisco"
        location.country = "USA"

        // When
        let address = location.fullAddress

        // Then
        XCTAssertEqual(address, "San Francisco, USA")
    }

    // MARK: - Distance Tests

    func test_distance_calculatesCorrectly() {
        // Given - San Francisco to Los Angeles (approx 560 km)
        let sanFrancisco = Location(context: context)
        sanFrancisco.latitude = 37.7749
        sanFrancisco.longitude = -122.4194

        let losAngeles = Location(context: context)
        losAngeles.latitude = 34.0522
        losAngeles.longitude = -118.2437

        // When
        let distance = sanFrancisco.distance(from: losAngeles)

        // Then - Distance should be approximately 560,000 meters
        XCTAssertGreaterThan(distance, 500_000)
        XCTAssertLessThan(distance, 600_000)
    }

    func test_distance_returnsZeroForSameLocation() {
        // Given
        let location1 = Location(context: context)
        location1.latitude = 37.7749
        location1.longitude = -122.4194

        let location2 = Location(context: context)
        location2.latitude = 37.7749
        location2.longitude = -122.4194

        // When
        let distance = location1.distance(from: location2)

        // Then
        XCTAssertLessThan(distance, 1) // Very close to zero
    }

    // MARK: - Emotional Metrics Tests

    func test_recalculateEmotionalMetrics_updatesFromNotes() {
        // Given
        let location = Location(context: context)

        let note1 = Note(context: context)
        let emotion1 = EmotionalState(context: context)
        emotion1.valence = 0.5
        emotion1.energyLevel = 0.6
        note1.moodSnapshot = emotion1
        note1.location = location

        let note2 = Note(context: context)
        let emotion2 = EmotionalState(context: context)
        emotion2.valence = 0.7
        emotion2.energyLevel = 0.8
        note2.moodSnapshot = emotion2
        note2.location = location

        location.notes.insert(note1)
        location.notes.insert(note2)

        // When
        location.recalculateEmotionalMetrics()

        // Then
        XCTAssertEqual(location.averageValence, 0.6, accuracy: 0.01)
        XCTAssertEqual(location.averageEnergy, 0.7, accuracy: 0.01)
    }

    // MARK: - PlaceType Tests

    func test_placeType_canBeSetAndRetrieved() {
        // Given
        let location = Location(context: context)

        // When
        location.placeType = .cafe

        // Then
        XCTAssertEqual(location.placeType, .cafe)
    }

    func test_placeType_allCasesHaveDisplayNames() {
        // Given/When/Then
        for type in PlaceType.allCases {
            XCTAssertFalse(type.displayName.isEmpty)
        }
    }

    func test_placeType_allCasesHaveEmojis() {
        // Given/When/Then
        for type in PlaceType.allCases {
            XCTAssertFalse(type.emoji.isEmpty)
        }
    }

    // MARK: - WeatherSnapshot Tests

    func test_weatherSnapshot_initialization() {
        // Given/When
        let weather = WeatherSnapshot(context: context)

        // Then
        XCTAssertNotNil(weather.id)
        XCTAssertNotNil(weather.timestamp)
        XCTAssertEqual(weather.temperature, 0)
        XCTAssertEqual(weather.conditions, .clear)
    }

    func test_weatherSnapshot_temperatureFahrenheit() {
        // Given
        let weather = WeatherSnapshot(context: context)
        weather.temperature = 20 // 20°C

        // When
        let fahrenheit = weather.temperatureFahrenheit

        // Then
        XCTAssertEqual(fahrenheit, 68, accuracy: 0.1) // 20°C = 68°F
    }

    func test_weatherSnapshot_weatherDescription() {
        // Given
        let weather = WeatherSnapshot(context: context)
        weather.conditions = .sunny
        weather.temperature = 25

        // When
        let description = weather.weatherDescription

        // Then
        XCTAssertTrue(description.contains("25.0°C"))
    }

    func test_weatherCondition_allCasesHaveDisplayNames() {
        // Given/When/Then
        for condition in WeatherCondition.allCases {
            XCTAssertFalse(condition.displayName.isEmpty)
        }
    }

    func test_weatherCondition_allCasesHaveEmojis() {
        // Given/When/Then
        for condition in WeatherCondition.allCases {
            XCTAssertFalse(condition.emoji.isEmpty)
        }
    }

    func test_airQualityCategory_allCasesHaveColors() {
        // Given/When/Then
        let categories: [AirQualityCategory] = [.good, .moderate, .unhealthySensitive, .unhealthy, .veryUnhealthy, .hazardous]
        for category in categories {
            XCTAssertTrue(category.color.hasPrefix("#"))
            XCTAssertEqual(category.color.count, 7)
        }
    }
}
