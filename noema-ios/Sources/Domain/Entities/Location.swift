import Foundation

/// Represents a geographic location associated with a note
public struct Location: Equatable, Codable, Sendable {
    // MARK: - Properties

    public let latitude: Double?
    public let longitude: Double?
    public let cityName: String?
    public let countryCode: String? // ISO country code
    public let placeName: String? // Specific place (e.g., "Starbucks", "Central Park")

    // MARK: - Initialization

    public init(
        latitude: Double? = nil,
        longitude: Double? = nil,
        cityName: String? = nil,
        countryCode: String? = nil,
        placeName: String? = nil
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.cityName = cityName
        self.countryCode = countryCode
        self.placeName = placeName
    }

    // MARK: - Computed Properties

    /// Check if location has GPS coordinates
    public var hasCoordinates: Bool {
        latitude != nil && longitude != nil
    }

    /// Display name for the location
    public var displayName: String {
        if let placeName = placeName {
            return placeName
        } else if let cityName = cityName {
            if let countryCode = countryCode {
                return "\(cityName), \(countryCode)"
            }
            return cityName
        } else if hasCoordinates {
            return coordinatesFormatted
        } else {
            return "Unknown Location"
        }
    }

    /// Formatted coordinates string
    public var coordinatesFormatted: String {
        guard let lat = latitude, let lon = longitude else {
            return "No coordinates"
        }
        return String(format: "%.4f°, %.4f°", lat, lon)
    }

    /// Country display name
    public var countryDisplayName: String? {
        guard let countryCode = countryCode else { return nil }
        return Locale.current.localizedString(forRegionCode: countryCode)
    }

    // MARK: - Privacy

    /// Get a privacy-safe version (city-level only, no GPS)
    public var privacySafe: Location {
        Location(
            latitude: nil,
            longitude: nil,
            cityName: cityName,
            countryCode: countryCode,
            placeName: nil
        )
    }
}

// MARK: - Sample Data

#if DEBUG
extension Location {
    public static var sample: Location {
        Location(
            latitude: 37.7749,
            longitude: -122.4194,
            cityName: "San Francisco",
            countryCode: "US",
            placeName: "Blue Bottle Coffee"
        )
    }

    public static var cityOnly: Location {
        Location(
            cityName: "New York",
            countryCode: "US"
        )
    }

    public static var coordinates: Location {
        Location(
            latitude: 51.5074,
            longitude: -0.1278
        )
    }
}
#endif
