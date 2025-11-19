//
//  HealthKitService.swift
//  Noema
//
//  Created on January 18, 2025.
//

import Foundation
import HealthKit

/// Service for integrating with HealthKit for biometric data
public final class HealthKitService {
    public static let shared = HealthKitService()

    private let healthStore = HKHealthStore()
    private let persistenceController = PersistenceController.shared

    private init() {}

    // MARK: - Authorization

    public func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }

        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .respiratoryRate)!
        ]

        try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
        Logger.services.info("HealthKit authorization granted")
    }

    // MARK: - Fetch Data

    public func fetchHeartRate(for date: Date) async throws -> Double? {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return nil
        }

        let startOfDay = date.startOfDay
        let endOfDay = date.endOfDay
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)

        let samples = try await fetchSamples(for: heartRateType, predicate: predicate)

        let heartRates = samples.compactMap { sample -> Double? in
            guard let quantitySample = sample as? HKQuantitySample else { return nil }
            return quantitySample.quantity.doubleValue(for: HKUnit(from: "count/min"))
        }

        return heartRates.isEmpty ? nil : heartRates.reduce(0, +) / Double(heartRates.count)
    }

    public func fetchStepCount(for date: Date) async throws -> Int? {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return nil
        }

        let startOfDay = date.startOfDay
        let endOfDay = date.endOfDay
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)

        let samples = try await fetchSamples(for: stepType, predicate: predicate)

        let steps = samples.compactMap { sample -> Double? in
            guard let quantitySample = sample as? HKQuantitySample else { return nil }
            return quantitySample.quantity.doubleValue(for: HKUnit.count())
        }

        return steps.isEmpty ? nil : Int(steps.reduce(0, +))
    }

    public func fetchSleepHours(for date: Date) async throws -> Double? {
        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else {
            return nil
        }

        let startOfDay = date.startOfDay
        let endOfDay = date.endOfDay
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)

        let samples = try await fetchSamples(for: sleepType, predicate: predicate)

        var totalSleepTime: TimeInterval = 0

        for sample in samples {
            guard let categorySample = sample as? HKCategorySample else { continue }
            if categorySample.value == HKCategoryValueSleepAnalysis.asleep.rawValue {
                totalSleepTime += categorySample.endDate.timeIntervalSince(categorySample.startDate)
            }
        }

        return totalSleepTime > 0 ? totalSleepTime / 3600 : nil // Convert to hours
    }

    // MARK: - Store Health Metrics

    public func storeHealthMetrics(for note: Note) async throws {
        guard let mood = note.moodSnapshot else { return }

        // Fetch health data for the note's date
        let heartRate = try await fetchHeartRate(for: note.createdAt)
        let steps = try await fetchStepCount(for: note.createdAt)
        let sleep = try await fetchSleepHours(for: note.createdAt.addingTimeInterval(-86400)) // Previous night

        try await persistenceController.performInBackground { context in
            if let heartRate = heartRate {
                let metric = HealthMetric(context: context)
                metric.id = UUID()
                metric.type = .heartRate
                metric.value = heartRate
                metric.timestamp = note.createdAt
                metric.associatedMood = mood
            }

            if let steps = steps {
                let metric = HealthMetric(context: context)
                metric.id = UUID()
                metric.type = .steps
                metric.value = Double(steps)
                metric.timestamp = note.createdAt
                metric.associatedMood = mood
            }

            if let sleep = sleep {
                let metric = HealthMetric(context: context)
                metric.id = UUID()
                metric.type = .sleep
                metric.value = sleep
                metric.timestamp = note.createdAt.addingTimeInterval(-86400)
                metric.associatedMood = mood
            }

            try context.save()
        }

        Logger.services.info("Stored health metrics for note")
    }

    // MARK: - Private Helpers

    private func fetchSamples(for sampleType: HKSampleType, predicate: NSPredicate) async throws -> [HKSample] {
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sampleType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: samples ?? [])
                }
            }

            healthStore.execute(query)
        }
    }
}

// MARK: - HealthKit Error

public enum HealthKitError: LocalizedError {
    case notAvailable
    case authorizationFailed

    public var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit is not available on this device"
        case .authorizationFailed:
            return "Failed to authorize HealthKit"
        }
    }
}
