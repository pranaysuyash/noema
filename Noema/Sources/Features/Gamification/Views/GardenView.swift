//
//  GardenView.swift
//  Noema
//
//  Created on January 19, 2025.
//

import SwiftUI

public struct GardenView: View {
    @StateObject private var viewModel = GamificationViewModel()
    @State private var selectedElement: GardenElement?
    @State private var showingInfo = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                // Garden background with gradient
                LinearGradient(
                    colors: [
                        Color.green.opacity(0.1),
                        Color.blue.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Garden stats header
                        GardenStatsHeader(viewModel: viewModel)

                        // Garden canvas
                        GardenCanvas(
                            gardenState: viewModel.gardenState,
                            selectedElement: $selectedElement
                        )
                        .frame(height: 400)

                        // Growth tips
                        GrowthTipsSection()

                        // Recent activity
                        RecentActivitySection(viewModel: viewModel)
                    }
                    .padding()
                }

                // Selected element detail
                if let element = selectedElement {
                    VStack {
                        Spacer()
                        ElementDetailPanel(element: element, onDismiss: {
                            selectedElement = nil
                        })
                        .transition(.move(edge: .bottom))
                    }
                }
            }
            .navigationTitle("Wellness Garden")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingInfo = true
                    } label: {
                        Image(systemName: "info.circle")
                    }
                }
            }
            .sheet(isPresented: $showingInfo) {
                GardenInfoSheet()
            }
            .loading(viewModel.isLoading)
            .errorAlert(error: $viewModel.error)
            .task {
                await viewModel.loadGarden()
            }
        }
    }

    enum GardenElement: Identifiable {
        case tree(GardenTree)
        case flower(GardenFlower)
        case vine(GardenVine)
        case crystal(GardenCrystal)

        var id: UUID {
            switch self {
            case .tree(let tree): return tree.id
            case .flower(let flower): return flower.id
            case .vine(let vine): return vine.id
            case .crystal(let crystal): return crystal.id
            }
        }
    }
}

// MARK: - Supporting Views

private struct GardenStatsHeader: View {
    @ObservedObject var viewModel: GamificationViewModel

    var body: some View {
        HStack(spacing: 16) {
            StatCard(
                icon: "🌳",
                label: "Trees",
                value: "\(viewModel.gardenState.trees.count)",
                color: .green
            )

            StatCard(
                icon: "🌸",
                label: "Flowers",
                value: "\(viewModel.gardenState.flowers.count)",
                color: .pink
            )

            StatCard(
                icon: "🌿",
                label: "Vines",
                value: "\(viewModel.gardenState.vines.count)",
                color: .green.opacity(0.7)
            )

            StatCard(
                icon: "💎",
                label: "Crystals",
                value: "\(viewModel.gardenState.crystals.count)",
                color: .achievementEpic
            )
        }
    }
}

private struct StatCard: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.title)

            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.noemaTextPrimary)

            Text(label)
                .font(.caption)
                .foregroundColor(.noemaTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

private struct GardenCanvas: View {
    let gardenState: GardenState
    @Binding var selectedElement: GardenView.GardenElement?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                seasonColor(gardenState.season).opacity(0.2),
                                seasonColor(gardenState.season).opacity(0.1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.noemaTextSecondary.opacity(0.2), lineWidth: 2)
                    )

                // Garden elements
                ForEach(gardenState.trees) { tree in
                    TreeView(tree: tree)
                        .position(tree.position)
                        .onTapGesture {
                            withAnimation {
                                selectedElement = .tree(tree)
                            }
                        }
                }

                ForEach(gardenState.flowers) { flower in
                    FlowerView(flower: flower)
                        .position(flower.position)
                        .onTapGesture {
                            withAnimation {
                                selectedElement = .flower(flower)
                            }
                        }
                }

                ForEach(gardenState.vines) { vine in
                    VineView(vine: vine)
                        .position(vine.position)
                        .onTapGesture {
                            withAnimation {
                                selectedElement = .vine(vine)
                            }
                        }
                }

                ForEach(gardenState.crystals) { crystal in
                    CrystalView(crystal: crystal)
                        .position(crystal.position)
                        .onTapGesture {
                            withAnimation {
                                selectedElement = .crystal(crystal)
                            }
                        }
                }

                // Season indicator
                VStack {
                    HStack {
                        Spacer()
                        SeasonBadge(season: gardenState.season)
                            .padding()
                    }
                    Spacer()
                }
            }
        }
        .cardStyle()
    }

    private func seasonColor(_ season: Season) -> Color {
        switch season {
        case .spring: return .green
        case .summer: return .yellow
        case .autumn: return .orange
        case .winter: return .blue
        }
    }
}

private struct TreeView: View {
    let tree: GardenTree

    var body: some View {
        Text(treeEmoji(tree.type, growth: tree.growthLevel))
            .font(.system(size: CGFloat(40 + tree.growthLevel * 10)))
    }

    private func treeEmoji(_ type: String, growth: Int) -> String {
        switch growth {
        case 0: return "🌱"
        case 1: return "🌿"
        case 2: return "🌳"
        default: return "🌲"
        }
    }
}

private struct FlowerView: View {
    let flower: GardenFlower

    var body: some View {
        Text(flowerEmoji(flower.type, bloom: flower.bloomLevel))
            .font(.system(size: CGFloat(30 + flower.bloomLevel * 8)))
    }

    private func flowerEmoji(_ type: String, bloom: Int) -> String {
        switch bloom {
        case 0: return "🌱"
        case 1: return "🌼"
        case 2: return "🌸"
        default: return "🌺"
        }
    }
}

private struct VineView: View {
    let vine: GardenVine

    var body: some View {
        Text("🌿")
            .font(.system(size: CGFloat(25 + vine.length * 5)))
            .rotationEffect(.degrees(Double(vine.length * 15)))
    }
}

private struct CrystalView: View {
    let crystal: GardenCrystal

    var body: some View {
        Text("💎")
            .font(.system(size: 35))
            .opacity(crystal.brightness)
    }
}

private struct SeasonBadge: View {
    let season: Season

    var body: some View {
        HStack(spacing: 6) {
            Text(seasonEmoji(season))
            Text(season.rawValue.capitalized)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.noemaCardBackground)
        .cornerRadius(16)
        .shadow(radius: 2)
    }

    private func seasonEmoji(_ season: Season) -> String {
        switch season {
        case .spring: return "🌸"
        case .summer: return "☀️"
        case .autumn: return "🍂"
        case .winter: return "❄️"
        }
    }
}

private struct ElementDetailPanel: View {
    let element: GardenView.GardenElement
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(elementTitle)
                    .font(.headline)
                    .foregroundColor(.noemaTextPrimary)

                Spacer()

                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.noemaTextSecondary)
                }
            }

            Text(elementDescription)
                .font(.subheadline)
                .foregroundColor(.noemaTextSecondary)

            elementMetrics
        }
        .padding()
        .background(Color.noemaCardBackground)
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .shadow(radius: 10)
        .padding(.horizontal)
    }

    private var elementTitle: String {
        switch element {
        case .tree: return "Growth Tree"
        case .flower: return "Bloom Flower"
        case .vine: return "Connection Vine"
        case .crystal: return "Insight Crystal"
        }
    }

    private var elementDescription: String {
        switch element {
        case .tree: return "Grows as you maintain your journaling streak"
        case .flower: return "Blooms when you express diverse emotions"
        case .vine: return "Extends as you discover connections between entities"
        case .crystal: return "Shines brighter with deep emotional insights"
        }
    }

    @ViewBuilder
    private var elementMetrics: some View {
        HStack(spacing: 20) {
            switch element {
            case .tree(let tree):
                Metric(label: "Growth Level", value: "\(tree.growthLevel)")
            case .flower(let flower):
                Metric(label: "Bloom Level", value: "\(flower.bloomLevel)")
            case .vine(let vine):
                Metric(label: "Length", value: "\(vine.length)")
            case .crystal(let crystal):
                Metric(label: "Brightness", value: "\(Int(crystal.brightness * 100))%")
            }
        }
    }
}

private struct Metric: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.noemaPrimary)

            Text(label)
                .font(.caption)
                .foregroundColor(.noemaTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct GrowthTipsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Growth Tips")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            TipRow(icon: "🌱", tip: "Journal daily to grow new trees")
            TipRow(icon: "🌸", tip: "Express diverse emotions to bloom flowers")
            TipRow(icon: "🌿", tip: "Make connections to extend vines")
            TipRow(icon: "💎", tip: "Reflect deeply to brighten crystals")
        }
        .padding()
        .cardStyle()
    }
}

private struct TipRow: View {
    let icon: String
    let tip: String

    var body: some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.title3)

            Text(tip)
                .font(.subheadline)
                .foregroundColor(.noemaTextPrimary)
        }
    }
}

private struct RecentActivitySection: View {
    @ObservedObject var viewModel: GamificationViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Growth")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            Text("Keep journaling to see your garden flourish!")
                .font(.subheadline)
                .foregroundColor(.noemaTextSecondary)
        }
        .padding()
        .cardStyle()
    }
}

private struct GardenInfoSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    InfoSection(
                        title: "What is the Wellness Garden?",
                        description: "Your personal garden grows as you journal and reflect. Each element represents different aspects of your emotional journey."
                    )

                    InfoSection(
                        title: "Trees 🌳",
                        description: "Trees grow taller with your consistency. Maintain daily journaling streaks to see them flourish."
                    )

                    InfoSection(
                        title: "Flowers 🌸",
                        description: "Flowers bloom when you express a wide range of emotions, celebrating emotional awareness."
                    )

                    InfoSection(
                        title: "Vines 🌿",
                        description: "Vines extend as you discover connections between people, places, and ideas in your notes."
                    )

                    InfoSection(
                        title: "Crystals 💎",
                        description: "Crystals shine brighter with deep, thoughtful reflections and meaningful insights."
                    )
                }
                .padding()
            }
            .navigationTitle("Garden Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct InfoSection: View {
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            Text(description)
                .font(.subheadline)
                .foregroundColor(.noemaTextSecondary)
        }
        .padding()
        .cardStyle()
    }
}

#Preview {
    GardenView()
}
