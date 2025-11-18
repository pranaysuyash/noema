import SwiftUI

/// Coordinator for mood tracking and analysis flows
/// Manages navigation between mood dashboard, timeline, logging, and insights
@MainActor
public final class MoodCoordinator: Coordinator {
    // MARK: - Coordinator Protocol

    public var parent: (any Coordinator)?
    public var children: [any Coordinator] = []

    // MARK: - Published Properties

    @Published public var navigationPath = NavigationPath()
    @Published public var isPresentingMoodLog: Bool = false
    @Published public var isPresentingInsights: Bool = false
    @Published public var isPresentingExport: Bool = false
    @Published public var selectedTimeRange: MoodTimeRange = .week
    @Published public var selectedMoodId: UUID?

    // MARK: - Dependencies

    private let moodRepository: MoodRepositoryProtocol
    private let noteRepository: NoteRepositoryProtocol

    // MARK: - Initialization

    public init(
        moodRepository: MoodRepositoryProtocol,
        noteRepository: NoteRepositoryProtocol,
        parent: (any Coordinator)? = nil
    ) {
        self.moodRepository = moodRepository
        self.noteRepository = noteRepository
        self.parent = parent
    }

    // MARK: - Coordinator Protocol

    public func start() {
        // Initial setup for mood flow
        // Could pre-load recent mood data, check for patterns, etc.
    }

    // MARK: - Navigation

    public func navigate(to destination: NavigationDestination) {
        switch destination {
        case .moodDashboard:
            popToRoot()

        case .moodTimeline:
            showTimeline()

        case .moodLog:
            showMoodLog()

        default:
            break
        }
    }

    public func showTimeline() {
        navigationPath.append(NavigationDestination.moodTimeline)
    }

    public func showMoodLog() {
        isPresentingMoodLog = true
    }

    public func showInsights() {
        isPresentingInsights = true
    }

    public func showExport() {
        isPresentingExport = true
    }

    public func dismissMoodLog() {
        isPresentingMoodLog = false
    }

    public func dismissInsights() {
        isPresentingInsights = false
    }

    public func dismissExport() {
        isPresentingExport = false
    }

    public func popToRoot() {
        navigationPath.removeLast(navigationPath.count)
        selectedMoodId = nil
    }

    // MARK: - Mood Actions

    public func logMood(_ mood: MoodSnapshot) async throws {
        _ = try await moodRepository.save(mood)
        dismissMoodLog()
    }

    public func updateTimeRange(_ range: MoodTimeRange) {
        selectedTimeRange = range
    }

    public func selectMood(_ moodId: UUID) {
        selectedMoodId = moodId
    }

    // MARK: - Mood Analysis

    public func getMoodTimeline(for range: MoodTimeRange) async throws -> [MoodSnapshot] {
        let dateRange = range.dateRange
        return try await moodRepository.fetchMoods(in: dateRange)
    }

    public func getEmotionDistribution(for range: MoodTimeRange) async throws -> [String: Int] {
        let moods = try await getMoodTimeline(for: range)

        var distribution: [String: Int] = [:]
        for mood in moods {
            let emotion = mood.dimensions.dominantEmotion
            distribution[emotion, default: 0] += 1
        }

        return distribution
    }

    public func getAverageMood(for range: MoodTimeRange) async throws -> EmotionalDimensions? {
        let moods = try await getMoodTimeline(for: range)
        guard !moods.isEmpty else { return nil }

        var sumJoy: Float = 0
        var sumSadness: Float = 0
        var sumAnger: Float = 0
        var sumFear: Float = 0
        var sumSurprise: Float = 0
        var sumDisgust: Float = 0
        var sumTrust: Float = 0
        var sumAnticipation: Float = 0

        for mood in moods {
            sumJoy += mood.dimensions.joy
            sumSadness += mood.dimensions.sadness
            sumAnger += mood.dimensions.anger
            sumFear += mood.dimensions.fear
            sumSurprise += mood.dimensions.surprise
            sumDisgust += mood.dimensions.disgust
            sumTrust += mood.dimensions.trust
            sumAnticipation += mood.dimensions.anticipation
        }

        let count = Float(moods.count)
        return EmotionalDimensions(
            joy: sumJoy / count,
            sadness: sumSadness / count,
            anger: sumAnger / count,
            fear: sumFear / count,
            surprise: sumSurprise / count,
            disgust: sumDisgust / count,
            trust: sumTrust / count,
            anticipation: sumAnticipation / count
        )
    }

    public func getMoodStreak() async throws -> Int {
        // Calculate current streak of days with mood logs
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var streak = 0
        var currentDate = today

        while true {
            let nextDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            let dateRange = currentDate...currentDate.addingTimeInterval(86400)

            let moodsForDay = try await moodRepository.fetchMoods(in: dateRange)

            if moodsForDay.isEmpty {
                break
            }

            streak += 1
            currentDate = nextDate

            // Safety limit
            if streak > 365 {
                break
            }
        }

        return streak
    }

    // MARK: - Correlations

    public func correlateMoodWithNotes(for range: MoodTimeRange) async throws -> [(mood: String, notes: [Note])] {
        let dateRange = range.dateRange
        let moods = try await moodRepository.fetchMoods(in: dateRange)
        let notes = try await noteRepository.fetchNotes(in: dateRange)

        var correlations: [String: [Note]] = [:]

        for note in notes {
            guard let noteMood = note.mood else { continue }
            let emotion = noteMood.dimensions.dominantEmotion
            correlations[emotion, default: []].append(note)
        }

        return correlations.map { (mood: $0.key, notes: $0.value) }
            .sorted { $0.notes.count > $1.notes.count }
    }

    public func findMoodPatterns(for range: MoodTimeRange) async throws -> [MoodPattern] {
        let moods = try await getMoodTimeline(for: range)
        var patterns: [MoodPattern] = []

        // Pattern 1: Dominant emotion
        if let mostCommonEmotion = moods.map({ $0.dimensions.dominantEmotion })
            .reduce(into: [:]) { counts, emotion in counts[emotion, default: 0] += 1 }
            .max(by: { $0.value < $1.value })?.key {
            patterns.append(.dominantEmotion(mostCommonEmotion))
        }

        // Pattern 2: Mood volatility
        let valences = moods.map { $0.dimensions.valence }
        if valences.count > 1 {
            let avgChange = zip(valences, valences.dropFirst())
                .map { abs($1 - $0) }
                .reduce(0, +) / Float(valences.count - 1)

            if avgChange > 0.3 {
                patterns.append(.highVolatility)
            } else if avgChange < 0.1 {
                patterns.append(.stable)
            }
        }

        // Pattern 3: Trending up/down
        if valences.count >= 3 {
            let firstThird = valences.prefix(valences.count / 3).reduce(0, +) / Float(valences.count / 3)
            let lastThird = valences.suffix(valences.count / 3).reduce(0, +) / Float(valences.count / 3)

            if lastThird - firstThird > 0.2 {
                patterns.append(.trendingPositive)
            } else if firstThird - lastThird > 0.2 {
                patterns.append(.trendingNegative)
            }
        }

        return patterns
    }

    // MARK: - Export

    public func exportMoodData(for range: MoodTimeRange, format: ExportFormat) async throws -> URL {
        let moods = try await getMoodTimeline(for: range)

        let fileName = "mood-export-\(Date().ISO8601Format()).\(format.fileExtension)"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        switch format {
        case .json:
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(moods)
            try data.write(to: tempURL)

        case .csv:
            var csv = "Timestamp,Dominant Emotion,Joy,Sadness,Anger,Fear,Surprise,Disgust,Trust,Anticipation,Valence,Arousal,Confidence,Source\n"

            for mood in moods {
                let dims = mood.dimensions
                csv += "\(mood.timestamp.ISO8601Format()),"
                csv += "\(dims.dominantEmotion),"
                csv += "\(dims.joy),\(dims.sadness),\(dims.anger),\(dims.fear),"
                csv += "\(dims.surprise),\(dims.disgust),\(dims.trust),\(dims.anticipation),"
                csv += "\(dims.valence),\(dims.arousal),"
                csv += "\(mood.confidence),\(mood.source.rawValue)\n"
            }

            try csv.write(to: tempURL, atomically: true, encoding: .utf8)

        case .pdf:
            // PDF generation would require more complex implementation
            // For now, create a simple text-based PDF
            throw CoordinatorError.invalidTransition
        }

        return tempURL
    }
}

// MARK: - Mood Time Range

public enum MoodTimeRange: String, CaseIterable, Identifiable {
    case day
    case week
    case month
    case quarter
    case year
    case all

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .day: return "Today"
        case .week: return "This Week"
        case .month: return "This Month"
        case .quarter: return "This Quarter"
        case .year: return "This Year"
        case .all: return "All Time"
        }
    }

    public var dateRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let now = Date()

        let start: Date
        switch self {
        case .day:
            start = calendar.startOfDay(for: now)
        case .week:
            start = calendar.date(byAdding: .day, value: -7, to: now)!
        case .month:
            start = calendar.date(byAdding: .month, value: -1, to: now)!
        case .quarter:
            start = calendar.date(byAdding: .month, value: -3, to: now)!
        case .year:
            start = calendar.date(byAdding: .year, value: -1, to: now)!
        case .all:
            start = Date.distantPast
        }

        return start...now
    }
}

// MARK: - Mood Pattern

public enum MoodPattern {
    case dominantEmotion(String)
    case highVolatility
    case stable
    case trendingPositive
    case trendingNegative

    public var title: String {
        switch self {
        case .dominantEmotion(let emotion):
            return "Mostly \(emotion)"
        case .highVolatility:
            return "High Mood Variability"
        case .stable:
            return "Stable Mood"
        case .trendingPositive:
            return "Improving Mood"
        case .trendingNegative:
            return "Declining Mood"
        }
    }

    public var description: String {
        switch self {
        case .dominantEmotion(let emotion):
            return "Your mood has been predominantly \(emotion) during this period."
        case .highVolatility:
            return "Your mood has been changing frequently. Consider what might be causing these fluctuations."
        case .stable:
            return "Your mood has been relatively consistent during this period."
        case .trendingPositive:
            return "Your mood has been improving over time. Keep doing what you're doing!"
        case .trendingNegative:
            return "Your mood has been declining. Consider reaching out to someone you trust."
        }
    }
}

// MARK: - Export Format

public enum ExportFormat: String, CaseIterable {
    case json
    case csv
    case pdf

    public var fileExtension: String {
        switch self {
        case .json: return "json"
        case .csv: return "csv"
        case .pdf: return "pdf"
        }
    }

    public var displayName: String {
        switch self {
        case .json: return "JSON"
        case .csv: return "CSV (Excel)"
        case .pdf: return "PDF Report"
        }
    }
}
