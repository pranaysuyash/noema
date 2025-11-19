//
//  QuestsView.swift
//  Noema
//
//  Created on January 19, 2025.
//

import SwiftUI

public struct QuestsView: View {
    @StateObject private var viewModel = GamificationViewModel()
    @State private var selectedQuest: Quest?

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Active quests
                    if !viewModel.activeQuests.isEmpty {
                        QuestSection(
                            title: "Active Quests",
                            quests: viewModel.activeQuests.filter { $0.isActive },
                            onSelect: { selectedQuest = $0 }
                        )
                    }

                    // Completed quests
                    if !viewModel.completedQuests.isEmpty {
                        QuestSection(
                            title: "Completed",
                            quests: viewModel.completedQuests,
                            onSelect: { selectedQuest = $0 }
                        )
                    }

                    // Expired quests
                    if !viewModel.expiredQuests.isEmpty {
                        QuestSection(
                            title: "Expired",
                            quests: viewModel.expiredQuests,
                            onSelect: { selectedQuest = $0 }
                        )
                    }
                }
                .padding()
            }
            .background(Color.noemaBackground)
            .navigationTitle("Quests")
            .sheet(item: $selectedQuest) { quest in
                QuestDetailSheet(quest: quest)
            }
            .loading(viewModel.isLoading)
            .errorAlert(error: $viewModel.error)
            .task {
                await viewModel.loadQuests()
            }
        }
    }
}

private struct QuestSection: View {
    let title: String
    let quests: [Quest]
    let onSelect: (Quest) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            ForEach(quests) { quest in
                QuestCard(quest: quest)
                    .onTapGesture {
                        onSelect(quest)
                    }
            }
        }
    }
}

private struct QuestCard: View {
    @ObservedObject var quest: Quest

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(quest.title)
                        .font(.headline)
                        .foregroundColor(.noemaTextPrimary)

                    Text(quest.questDescription)
                        .font(.subheadline)
                        .foregroundColor(.noemaTextSecondary)
                        .lineLimit(2)
                }

                Spacer()

                if quest.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.green)
                }
            }

            if !quest.isCompleted {
                VStack(spacing: 6) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                                .cornerRadius(4)

                            Rectangle()
                                .fill(Color.noemaPrimary)
                                .frame(width: geometry.size.width * quest.progressPercentage, height: 8)
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)

                    HStack {
                        Text("\(quest.currentProgress)/\(quest.targetValue)")
                            .font(.caption)
                            .foregroundColor(.noemaTextSecondary)

                        Spacer()

                        if quest.isActive {
                            Label("\(quest.daysRemaining)d left", systemImage: "clock")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }

            HStack {
                Label(quest.type.displayName, systemImage: "tag")
                    .font(.caption)
                    .foregroundColor(.noemaTextSecondary)

                Spacer()

                Label("+\(quest.xpReward) XP", systemImage: "star.fill")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.xpGold)
            }
        }
        .padding()
        .cardStyle()
        .opacity(quest.isCompleted || quest.isExpired ? 0.7 : 1.0)
    }
}

private struct QuestDetailSheet: View {
    @ObservedObject var quest: Quest
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(quest.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.noemaTextPrimary)

                    Text(quest.questDescription)
                        .font(.body)
                        .foregroundColor(.noemaTextSecondary)

                    Divider()

                    VStack(spacing: 12) {
                        MetricRow(label: "Type", value: quest.type.displayName)
                        MetricRow(label: "Duration", value: quest.duration.rawValue.capitalized)
                        MetricRow(label: "XP Reward", value: "+\(quest.xpReward)")

                        if quest.isActive {
                            MetricRow(label: "Days Remaining", value: "\(quest.daysRemaining)")
                        }

                        if !quest.isCompleted {
                            MetricRow(label: "Progress", value: "\(quest.currentProgress) / \(quest.targetValue)")
                            ProgressView(value: quest.progressPercentage)
                                .tint(.noemaPrimary)
                        }
                    }
                }
                .padding()
            }
            .background(Color.noemaBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

private struct MetricRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.noemaTextSecondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.noemaTextPrimary)
        }
        .padding()
        .background(Color.noemaCardBackground)
        .cornerRadius(10)
    }
}

#Preview {
    QuestsView()
}
