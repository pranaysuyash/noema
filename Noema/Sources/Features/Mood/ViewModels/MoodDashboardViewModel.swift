//
//  MoodDashboardViewModel.swift
//  Noema
//
//  Created on January 18, 2025.
//

import Foundation
import CoreData
import Combine

@MainActor
public final class MoodDashboardViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published public var currentMood: EmotionalState?
    @Published public var moodHistory: [EmotionalState] = []
    @Published public var moodPatterns: [EmotionalPattern] = []
    @Published public var moodInsights: [String] = []
    @Published public var selectedTimeRange: TimeRange = .week
    @Published public var isLoading: Bool = false
    @Published public var error: Error?

    // MARK: - Time Range

    public enum TimeRange: String, CaseIterable {
        case day = "Today"
        case week = "This Week"
        case month = "This Month"
        case year = "This Year"
        case all = "All Time"

        var dateRange: ClosedRange<Date> {
            let now = Date()
            switch self {
            case .day:
                return now.startOfDay...now.endOfDay
            case .week:
                return now.startOfWeek...now.endOfWeek
            case .month:
                let start = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: now))!
                let end = Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: start)!
                return start...end
            case .year:
                let start = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: now)))!
                let end = Calendar.current.date(byAdding: DateComponents(year: 1, day: -1), to: start)!
                return start...end
            case .all:
                return Date.distantPast...Date.distantFuture
            }
        }
    }

    // MARK: - Dependencies

    private let emotionService: EmotionAnalysisService
    private let persistenceController: PersistenceController
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    public init(
        emotionService: EmotionAnalysisService = EmotionAnalysisService(),
        persistenceController: PersistenceController = .shared
    ) {
        self.emotionService = emotionService
        self.persistenceController = persistenceController

        setupBindings()
    }

    // MARK: - Setup

    private func setupBindings() {
        $selectedTimeRange
            .sink { [weak self] _ in
                Task { await self?.fetchMoodData() }
            }
            .store(in: &cancellables)
    }

    // MARK: - Public Methods

    public func fetchMoodData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // Fetch mood history
            moodHistory = try await fetchMoodHistory()

            // Get current mood (most recent)
            currentMood = moodHistory.first

            // Get patterns
            moodPatterns = try await emotionService.getEmotionalPatterns(
                startDate: selectedTimeRange.dateRange.lowerBound,
                endDate: selectedTimeRange.dateRange.upperBound
            )

            // Generate insights
            moodInsights = try await emotionService.generateInsights(
                startDate: selectedTimeRange.dateRange.lowerBound,
                endDate: selectedTimeRange.dateRange.upperBound
            )
        } catch {
            self.error = error
            Logger.ui.error("Failed to fetch mood data", error: error)
        }
    }

    public func predictMood() async -> EmotionalState? {
        do {
            return try await emotionService.predictMood()
        } catch {
            Logger.ui.error("Failed to predict mood", error: error)
            return nil
        }
    }

    // MARK: - Private Methods

    private func fetchMoodHistory() async throws -> [EmotionalState] {
        return try await persistenceController.performInBackground { context in
            let request: NSFetchRequest<EmotionalState> = EmotionalState.fetchRequest()
            request.predicate = NSPredicate(
                format: "timestamp >= %@ AND timestamp <= %@",
                self.selectedTimeRange.dateRange.lowerBound as NSDate,
                self.selectedTimeRange.dateRange.upperBound as NSDate
            )
            request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
            request.fetchLimit = 100

            return try context.fetch(request)
        }
    }
}
