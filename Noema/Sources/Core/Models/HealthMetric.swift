import Foundation
import CoreData
import HealthKit

// MARK: - HealthMetric Model

/// Stores health and biometric data from HealthKit for correlation analysis
@objc(HealthMetric)
public class HealthMetric: NSManagedObject, Identifiable {

    // MARK: - Identity

    @NSManaged public var id: UUID
    @NSManaged public var timestamp: Date

    // MARK: - Metric

    @NSManaged private var metricTypeRaw: String
    @NSManaged public var value: Double
    @NSManaged public var unit: String

    public var metricType: HealthMetricType {
        get {
            HealthMetricType(rawValue: metricTypeRaw) ?? .steps
        }
        set {
            metricTypeRaw = newValue.rawValue
        }
    }

    // MARK: - Correlation

    @NSManaged public var correlatedMood: EmotionalState?

    // MARK: - Privacy

    @NSManaged public var isShared: Bool  // Never shared by default

    // MARK: - Computed Properties

    public var displayValue: String {
        String(format: "%.1f %@", value, unit)
    }

    public var formattedValue: String {
        switch metricType {
        case .sleepDuration:
            let hours = Int(value)
            let minutes = Int((value - Double(hours)) * 60)
            return "\(hours)h \(minutes)m"
        case .steps:
            return "\(Int(value)) steps"
        case .heartRate, .restingHeartRate:
            return "\(Int(value)) bpm"
        case .mindfulMinutes, .exerciseMinutes:
            return "\(Int(value)) min"
        default:
            return displayValue
        }
    }

    // MARK: - Initialization

    public override func awakeFromInsert() {
        super.awakeFromInsert()

        id = UUID()
        timestamp = Date()
        metricType = .steps
        value = 0
        unit = ""
        isShared = false
    }
}

// MARK: - HealthMetricType Enum

public enum HealthMetricType: String, Codable, CaseIterable {
    case sleepDuration
    case sleepQuality
    case steps
    case activeEnergyBurned
    case heartRate
    case heartRateVariability
    case restingHeartRate
    case mindfulMinutes
    case standHours
    case exerciseMinutes
    case vo2Max
    case bodyMass

    public var displayName: String {
        switch self {
        case .sleepDuration: return "Sleep Duration"
        case .sleepQuality: return "Sleep Quality"
        case .steps: return "Steps"
        case .activeEnergyBurned: return "Active Energy"
        case .heartRate: return "Heart Rate"
        case .heartRateVariability: return "Heart Rate Variability"
        case .restingHeartRate: return "Resting Heart Rate"
        case .mindfulMinutes: return "Mindful Minutes"
        case .standHours: return "Stand Hours"
        case .exerciseMinutes: return "Exercise Minutes"
        case .vo2Max: return "VO2 Max"
        case .bodyMass: return "Body Mass"
        }
    }

    public var unit: String {
        switch self {
        case .sleepDuration: return "hours"
        case .sleepQuality: return "score"
        case .steps: return "steps"
        case .activeEnergyBurned: return "kcal"
        case .heartRate, .restingHeartRate: return "bpm"
        case .heartRateVariability: return "ms"
        case .mindfulMinutes, .exerciseMinutes: return "min"
        case .standHours: return "hours"
        case .vo2Max: return "mL/kg/min"
        case .bodyMass: return "kg"
        }
    }

    public var sfSymbol: String {
        switch self {
        case .sleepDuration, .sleepQuality: return "bed.double.fill"
        case .steps: return "figure.walk"
        case .activeEnergyBurned: return "flame.fill"
        case .heartRate, .restingHeartRate: return "heart.fill"
        case .heartRateVariability: return "waveform.path.ecg"
        case .mindfulMinutes: return "brain.head.profile"
        case .standHours: return "figure.stand"
        case .exerciseMinutes: return "figure.run"
        case .vo2Max: return "lungs.fill"
        case .bodyMass: return "scalemass.fill"
        }
    }

    // Map to HealthKit types
    @available(iOS 13.0, *)
    public var healthKitType: HKQuantityType? {
        switch self {
        case .sleepDuration:
            return HKQuantityType.categoryType(forIdentifier: .sleepAnalysis) as? HKQuantityType
        case .sleepQuality:
            return nil  // Computed from sleep analysis
        case .steps:
            return HKQuantityType.quantityType(forIdentifier: .stepCount)
        case .activeEnergyBurned:
            return HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)
        case .heartRate:
            return HKQuantityType.quantityType(forIdentifier: .heartRate)
        case .heartRateVariability:
            return HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)
        case .restingHeartRate:
            return HKQuantityType.quantityType(forIdentifier: .restingHeartRate)
        case .mindfulMinutes:
            return HKQuantityType.categoryType(forIdentifier: .mindfulSession) as? HKQuantityType
        case .standHours:
            return HKQuantityType.categoryType(forIdentifier: .appleStandHour) as? HKQuantityType
        case .exerciseMinutes:
            return HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)
        case .vo2Max:
            return HKQuantityType.quantityType(forIdentifier: .vo2Max)
        case .bodyMass:
            return HKQuantityType.quantityType(forIdentifier: .bodyMass)
        }
    }
}

// MARK: - HealthKit Integration Helpers

@available(iOS 13.0, *)
extension HealthMetric {

    /// Create HealthMetric from HKQuantitySample
    public static func from(sample: HKQuantitySample, type: HealthMetricType) -> HealthMetric? {
        guard let metric = NSEntityDescription.insertNewObject(
            forEntityName: "HealthMetric",
            into: PersistenceController.shared.container.viewContext
        ) as? HealthMetric else {
            return nil
        }

        metric.id = UUID()
        metric.timestamp = sample.startDate
        metric.metricType = type

        switch type {
        case .steps:
            metric.value = sample.quantity.doubleValue(for: HKUnit.count())
            metric.unit = "steps"
        case .activeEnergyBurned:
            metric.value = sample.quantity.doubleValue(for: HKUnit.kilocalorie())
            metric.unit = "kcal"
        case .heartRate, .restingHeartRate:
            metric.value = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            metric.unit = "bpm"
        case .heartRateVariability:
            metric.value = sample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
            metric.unit = "ms"
        case .exerciseMinutes:
            metric.value = sample.quantity.doubleValue(for: HKUnit.minute())
            metric.unit = "min"
        case .vo2Max:
            metric.value = sample.quantity.doubleValue(for: HKUnit(from: "mL/kg/min"))
            metric.unit = "mL/kg/min"
        case .bodyMass:
            metric.value = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            metric.unit = "kg"
        default:
            metric.value = 0
            metric.unit = type.unit
        }

        return metric
    }
}

// MARK: - Placeholder for PersistenceController (will be created in Services)

/// Temporary placeholder - will be replaced with actual PersistenceController
fileprivate struct PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Noema")
        return container
    }()
}
