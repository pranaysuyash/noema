import Foundation
import CoreData
import CoreLocation

// MARK: - Location Model

/// Represents a physical location where a note was created
@objc(Location)
public class Location: NSManagedObject, Identifiable {

    // MARK: - Identity

    @NSManaged public var id: UUID

    // MARK: - Coordinates

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var altitude: Double

    // MARK: - Place Information

    @NSManaged public var placeName: String?
    @NSManaged public var city: String?
    @NSManaged public var state: String?
    @NSManaged public var country: String?
    @NSManaged private var placeTypeRaw: String?

    public var placeType: PlaceType? {
        get {
            guard let raw = placeTypeRaw else { return nil }
            return PlaceType(rawValue: raw)
        }
        set {
            placeTypeRaw = newValue?.rawValue
        }
    }

    // MARK: - Emotional Associations

    @NSManaged public var averageValence: Double
    @NSManaged public var averageEnergy: Double
    @NSManaged public var visitCount: Int

    // MARK: - Metadata

    @NSManaged public var firstVisit: Date
    @NSManaged public var lastVisit: Date

    // MARK: - User Control

    @NSManaged public var isPrivate: Bool
    @NSManaged public var customLabel: String?

    // MARK: - Relationships

    @NSManaged public var notes: Set<Note>

    // MARK: - Computed Properties

    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    public var clLocation: CLLocation {
        CLLocation(
            coordinate: coordinate,
            altitude: altitude,
            horizontalAccuracy: kCLLocationAccuracyBest,
            verticalAccuracy: kCLLocationAccuracyBest,
            timestamp: lastVisit
        )
    }

    public var displayName: String {
        customLabel ?? placeName ?? city ?? "Unknown Location"
    }

    public var fullAddress: String {
        [placeName, city, state, country]
            .compactMap { $0 }
            .joined(separator: ", ")
    }

    // MARK: - Initialization

    public override func awakeFromInsert() {
        super.awakeFromInsert()

        id = UUID()
        latitude = 0
        longitude = 0
        altitude = 0
        averageValence = 0
        averageEnergy = 0
        visitCount = 0
        firstVisit = Date()
        lastVisit = Date()
        isPrivate = false
        notes = Set()
    }

    // MARK: - Methods

    /// Update emotional metrics based on notes created at this location
    public func recalculateEmotionalMetrics() {
        let notesArray = Array(notes)
        guard !notesArray.isEmpty else { return }

        let emotions = notesArray.compactMap { $0.moodSnapshot }
        guard !emotions.isEmpty else { return }

        averageValence = emotions.reduce(0) { $0 + $1.valence } / Double(emotions.count)
        averageEnergy = emotions.reduce(0) { $0 + $1.energyLevel } / Double(emotions.count)
    }

    /// Calculate distance from another location
    public func distance(from location: Location) -> CLLocationDistance {
        let fromLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let toLocation = CLLocation(latitude: latitude, longitude: longitude)
        return fromLocation.distance(from: toLocation)
    }
}

// MARK: - PlaceType Enum

public enum PlaceType: String, Codable, CaseIterable {
    case home
    case work
    case cafe
    case gym
    case outdoor
    case transit
    case restaurant
    case social
    case other

    public var displayName: String {
        rawValue.capitalized
    }

    public var emoji: String {
        switch self {
        case .home: return "🏠"
        case .work: return "💼"
        case .cafe: return "☕"
        case .gym: return "🏋️"
        case .outdoor: return "🌳"
        case .transit: return "🚇"
        case .restaurant: return "🍽️"
        case .social: return "🎉"
        case .other: return "📍"
        }
    }
}

// MARK: - WeatherSnapshot Model

/// Captures weather conditions at the time of note creation
@objc(WeatherSnapshot)
public class WeatherSnapshot: NSManagedObject, Identifiable {

    // MARK: - Identity

    @NSManaged public var id: UUID
    @NSManaged public var timestamp: Date

    // MARK: - Weather Conditions

    @NSManaged public var temperature: Double        // Celsius
    @NSManaged public var feelsLike: Double
    @NSManaged public var humidity: Double           // Percentage
    @NSManaged public var pressure: Double           // hPa

    @NSManaged private var conditionsRaw: String
    @NSManaged public var cloudCover: Double         // Percentage
    @NSManaged public var visibility: Double         // Kilometers

    @NSManaged public var windSpeed: Double          // km/h
    @NSManaged public var windDirection: Double      // Degrees

    public var conditions: WeatherCondition {
        get {
            WeatherCondition(rawValue: conditionsRaw) ?? .clear
        }
        set {
            conditionsRaw = newValue.rawValue
        }
    }

    // MARK: - Air Quality

    @NSManaged public var airQualityIndex: Int
    @NSManaged private var airQualityCategoryRaw: String?

    public var airQualityCategory: AirQualityCategory? {
        get {
            guard let raw = airQualityCategoryRaw else { return nil }
            return AirQualityCategory(rawValue: raw)
        }
        set {
            airQualityCategoryRaw = newValue?.rawValue
        }
    }

    // MARK: - Sun

    @NSManaged public var uvIndex: Int
    @NSManaged public var sunrise: Date?
    @NSManaged public var sunset: Date?

    // MARK: - Relationships

    @NSManaged public var notes: Set<Note>

    // MARK: - Computed Properties

    public var temperatureFahrenheit: Double {
        (temperature * 9/5) + 32
    }

    public var isNightTime: Bool {
        guard let sunrise = sunrise, let sunset = sunset else { return false }
        return timestamp < sunrise || timestamp > sunset
    }

    public var weatherDescription: String {
        let temp = String(format: "%.1f°C", temperature)
        return "\(conditions.emoji) \(conditions.displayName), \(temp)"
    }

    // MARK: - Initialization

    public override func awakeFromInsert() {
        super.awakeFromInsert()

        id = UUID()
        timestamp = Date()
        temperature = 0
        feelsLike = 0
        humidity = 0
        pressure = 0
        conditions = .clear
        cloudCover = 0
        visibility = 0
        windSpeed = 0
        windDirection = 0
        airQualityIndex = 0
        uvIndex = 0
        notes = Set()
    }
}

// MARK: - Weather Enums

public enum WeatherCondition: String, Codable, CaseIterable {
    case clear
    case partlyCloudy
    case cloudy
    case rainy
    case snowy
    case foggy
    case stormy
    case windy

    public var displayName: String {
        switch self {
        case .clear: return "Clear"
        case .partlyCloudy: return "Partly Cloudy"
        case .cloudy: return "Cloudy"
        case .rainy: return "Rainy"
        case .snowy: return "Snowy"
        case .foggy: return "Foggy"
        case .stormy: return "Stormy"
        case .windy: return "Windy"
        }
    }

    public var emoji: String {
        switch self {
        case .clear: return "☀️"
        case .partlyCloudy: return "⛅"
        case .cloudy: return "☁️"
        case .rainy: return "🌧️"
        case .snowy: return "❄️"
        case .foggy: return "🌫️"
        case .stormy: return "⛈️"
        case .windy: return "💨"
        }
    }
}

public enum AirQualityCategory: String, Codable {
    case good
    case moderate
    case unhealthySensitive = "unhealthy_sensitive"
    case unhealthy
    case veryUnhealthy = "very_unhealthy"
    case hazardous

    public var displayName: String {
        switch self {
        case .good: return "Good"
        case .moderate: return "Moderate"
        case .unhealthySensitive: return "Unhealthy for Sensitive Groups"
        case .unhealthy: return "Unhealthy"
        case .veryUnhealthy: return "Very Unhealthy"
        case .hazardous: return "Hazardous"
        }
    }

    public var color: String {
        switch self {
        case .good: return "#00E400"
        case .moderate: return "#FFFF00"
        case .unhealthySensitive: return "#FF7E00"
        case .unhealthy: return "#FF0000"
        case .veryUnhealthy: return "#8F3F97"
        case .hazardous: return "#7E0023"
        }
    }
}
