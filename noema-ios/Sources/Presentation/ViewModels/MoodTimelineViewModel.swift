import SwiftUI

/// ViewModel for the mood timeline screen
/// Shows detailed mood history with charts and insights
@MainActor
public final class MoodTimelineViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published public var moods: [MoodSnapshot] = []
    @Published public var isLoading: Bool = false
    @Published public var error: Error?
    @Published public var selectedTimeRange: MoodTimeRange = .month
    @Published public var chartData: [ChartDataPoint] = []
    @Published public var selectedMood: MoodSnapshot?

    // MARK: - Dependencies

    private let moodRepository: MoodRepositoryProtocol

    // MARK: - Initialization

    public init(moodRepository: MoodRepositoryProtocol) {
        self.moodRepository = moodRepository
    }

    // MARK: - Public Methods

    public func loadTimeline() async {
        isLoading = true
        error = nil

        do {
            let dateRange = selectedTimeRange.dateRange
            moods = try await moodRepository.fetchMoods(in: dateRange)
            generateChartData()
        } catch {
            self.error = error
        }

        isLoading = false
    }

    public func refresh() async {
        await loadTimeline()
    }

    public func updateTimeRange(_ range: MoodTimeRange) async {
        selectedTimeRange = range
        await loadTimeline()
    }

    public func selectMood(_ mood: MoodSnapshot) {
        selectedMood = mood
    }

    public func deselectMood() {
        selectedMood = nil
    }

    // MARK: - Private Methods

    private func generateChartData() {
        chartData = moods.map { mood in
            ChartDataPoint(
                date: mood.timestamp,
                valence: mood.dimensions.valence,
                arousal: mood.dimensions.arousal,
                dominantEmotion: mood.dimensions.dominantEmotion,
                confidence: mood.confidence
            )
        }
    }
}

// MARK: - Chart Data Point

public struct ChartDataPoint: Identifiable {
    public let id = UUID()
    public let date: Date
    public let valence: Float  // -1 to 1
    public let arousal: Float  // 0 to 1
    public let dominantEmotion: String
    public let confidence: Float

    public var color: Color {
        // Map emotions to colors
        switch dominantEmotion.lowercased() {
        case "joy":
            return .yellow
        case "sadness":
            return .blue
        case "anger":
            return .red
        case "fear":
            return .purple
        case "surprise":
            return .orange
        case "disgust":
            return .green
        case "trust":
            return .cyan
        case "anticipation":
            return .pink
        default:
            return .gray
        }
    }
}
