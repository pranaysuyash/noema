import SwiftUI

/// ViewModel for the mood dashboard screen
/// Shows mood overview, patterns, and quick stats
@MainActor
public final class MoodDashboardViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published public var currentMood: MoodSnapshot?
    @Published public var recentMoods: [MoodSnapshot] = []
    @Published public var moodStreak: Int = 0
    @Published public var emotionDistribution: [String: Int] = [:]
    @Published public var averageMood: EmotionalDimensions?
    @Published public var moodPatterns: [MoodPattern] = []
    @Published public var isLoading: Bool = false
    @Published public var error: Error?
    @Published public var selectedTimeRange: MoodTimeRange = .week

    // MARK: - Dependencies

    private let moodRepository: MoodRepositoryProtocol
    private let noteRepository: NoteRepositoryProtocol

    // MARK: - Initialization

    public init(
        moodRepository: MoodRepositoryProtocol,
        noteRepository: NoteRepositoryProtocol
    ) {
        self.moodRepository = moodRepository
        self.noteRepository = noteRepository
    }

    // MARK: - Public Methods

    public func loadDashboard() async {
        isLoading = true
        error = nil

        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadRecentMoods() }
            group.addTask { await self.loadMoodStreak() }
            group.addTask { await self.loadEmotionDistribution() }
            group.addTask { await self.loadAverageMood() }
            group.addTask { await self.loadMoodPatterns() }
        }

        isLoading = false
    }

    public func refresh() async {
        await loadDashboard()
    }

    public func updateTimeRange(_ range: MoodTimeRange) async {
        selectedTimeRange = range
        await loadDashboard()
    }

    // MARK: - Private Methods

    private func loadRecentMoods() async {
        do {
            recentMoods = try await moodRepository.fetchRecent(limit: 7)
            currentMood = recentMoods.first
        } catch {
            self.error = error
        }
    }

    private func loadMoodStreak() async {
        do {
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

                if streak > 365 {
                    break
                }
            }

            moodStreak = streak
        } catch {
            print("Failed to load mood streak: \(error)")
        }
    }

    private func loadEmotionDistribution() async {
        do {
            let dateRange = selectedTimeRange.dateRange
            let moods = try await moodRepository.fetchMoods(in: dateRange)

            var distribution: [String: Int] = [:]
            for mood in moods {
                let emotion = mood.dimensions.dominantEmotion
                distribution[emotion, default: 0] += 1
            }

            emotionDistribution = distribution
        } catch {
            print("Failed to load emotion distribution: \(error)")
        }
    }

    private func loadAverageMood() async {
        do {
            let dateRange = selectedTimeRange.dateRange
            let moods = try await moodRepository.fetchMoods(in: dateRange)

            guard !moods.isEmpty else {
                averageMood = nil
                return
            }

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
            averageMood = EmotionalDimensions(
                joy: sumJoy / count,
                sadness: sumSadness / count,
                anger: sumAnger / count,
                fear: sumFear / count,
                surprise: sumSurprise / count,
                disgust: sumDisgust / count,
                trust: sumTrust / count,
                anticipation: sumAnticipation / count
            )
        } catch {
            print("Failed to load average mood: \(error)")
        }
    }

    private func loadMoodPatterns() async {
        do {
            let dateRange = selectedTimeRange.dateRange
            let moods = try await moodRepository.fetchMoods(in: dateRange)
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

            moodPatterns = patterns
        } catch {
            print("Failed to load mood patterns: \(error)")
        }
    }
}
