//
//  WeatherService.swift
//  Noema
//
//  Created on January 18, 2025.
//

import Foundation
import WeatherKit
import CoreLocation

/// Service for fetching weather data
public final class WeatherService {
    public static let shared = WeatherService()

    private let weatherService = WeatherKit.WeatherService.shared
    private let persistenceController = PersistenceController.shared

    private init() {}

    // MARK: - Fetch Weather

    public func fetchWeather(for location: CLLocation, date: Date = Date()) async throws -> WeatherSnapshot? {
        do {
            let weather = try await weatherService.weather(for: location, including: .current)

            return try await persistenceController.performInBackground { context in
                let snapshot = WeatherSnapshot(context: context)
                snapshot.id = UUID()
                snapshot.timestamp = date
                snapshot.latitude = location.coordinate.latitude
                snapshot.longitude = location.coordinate.longitude

                // Current conditions
                snapshot.temperature = weather.temperature.value
                snapshot.feelsLike = weather.apparentTemperature.value
                snapshot.humidity = weather.humidity
                snapshot.pressure = weather.pressure.value
                snapshot.windSpeed = weather.wind.speed.value
                snapshot.cloudCover = weather.cloudCover
                snapshot.uvIndex = Double(weather.uvIndex.value)

                // Condition
                snapshot.condition = weather.condition.description

                try context.save()
                return snapshot
            }
        } catch {
            Logger.services.error("Failed to fetch weather", error: error)
            throw error
        }
    }

    public func fetchWeatherForNote(_ note: Note) async throws {
        guard let location = note.location else { return }

        let clLocation = CLLocation(
            latitude: location.latitude,
            longitude: location.longitude
        )

        let weather = try await fetchWeather(for: clLocation, date: note.createdAt)
        note.weather = weather

        try persistenceController.save()
        Logger.services.info("Weather data added to note")
    }
}
