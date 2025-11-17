import Foundation

/// Represents weather conditions at the time a note was created
public struct WeatherSnapshot: Equatable, Codable, Sendable {
    // MARK: - Properties

    public let timestamp: Date
    public let temperature: Float? // Celsius
    public let condition: WeatherCondition?
    public let humidity: Float? // Percentage 0-100

    // MARK: - Initialization

    public init(
        timestamp: Date = Date(),
        temperature: Float? = nil,
        condition: WeatherCondition? = nil,
        humidity: Float? = nil
    ) {
        self.timestamp = timestamp
        self.temperature = temperature
        self.condition = condition
        self.humidity = humidity
    }

    // MARK: - Computed Properties

    /// Temperature in Fahrenheit
    public var temperatureFahrenheit: Float? {
        guard let celsius = temperature else { return nil }
        return celsius * 9.0 / 5.0 + 32.0
    }

    /// Temperature formatted for current locale
    public var temperatureFormatted: String {
        guard let temp = temperature else { return "Unknown" }

        let measurement = Measurement(value: Double(temp), unit: UnitTemperature.celsius)
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        return formatter.string(from: measurement)
    }

    /// Display description
    public var description: String {
        var parts: [String] = []

        if let condition = condition {
            parts.append(condition.label)
        }

        if let temp = temperature {
            parts.append(String(format: "%.1f°C", temp))
        }

        if let humidity = humidity {
            parts.append(String(format: "%.0f%% humidity", humidity))
        }

        return parts.isEmpty ? "No weather data" : parts.joined(separator: ", ")
    }
}

/// Common weather conditions
public enum WeatherCondition: String, Codable, Sendable, CaseIterable {
    case clear
    case cloudy
    case partlyCloudy
    case rainy
    case stormy
    case snowy
    case foggy
    case windy

    public var label: String {
        switch self {
        case .clear:
            return "Clear"
        case .cloudy:
            return "Cloudy"
        case .partlyCloudy:
            return "Partly Cloudy"
        case .rainy:
            return "Rainy"
        case .stormy:
            return "Stormy"
        case .snowy:
            return "Snowy"
        case .foggy:
            return "Foggy"
        case .windy:
            return "Windy"
        }
    }

    public var iconName: String {
        switch self {
        case .clear:
            return "sun.max.fill"
        case .cloudy:
            return "cloud.fill"
        case .partlyCloudy:
            return "cloud.sun.fill"
        case .rainy:
            return "cloud.rain.fill"
        case .stormy:
            return "cloud.bolt.fill"
        case .snowy:
            return "snowflake"
        case .foggy:
            return "cloud.fog.fill"
        case .windy:
            return "wind"
        }
    }

    public var emoji: String {
        switch self {
        case .clear:
            return "☀️"
        case .cloudy:
            return "☁️"
        case .partlyCloudy:
            return "⛅"
        case .rainy:
            return "🌧️"
        case .stormy:
            return "⛈️"
        case .snowy:
            return "❄️"
        case .foggy:
            return "🌫️"
        case .windy:
            return "💨"
        }
    }
}

// MARK: - Sample Data

#if DEBUG
extension WeatherSnapshot {
    public static var sample: WeatherSnapshot {
        WeatherSnapshot(
            temperature: 22.0,
            condition: .partlyCloudy,
            humidity: 65.0
        )
    }

    public static var sunny: WeatherSnapshot {
        WeatherSnapshot(
            temperature: 28.0,
            condition: .clear,
            humidity: 45.0
        )
    }

    public static var rainy: WeatherSnapshot {
        WeatherSnapshot(
            temperature: 15.0,
            condition: .rainy,
            humidity: 85.0
        )
    }
}
#endif
