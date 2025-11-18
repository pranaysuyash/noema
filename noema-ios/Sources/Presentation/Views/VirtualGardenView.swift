import SwiftUI

/// Virtual garden view showing user's plants
public struct VirtualGardenView: View {
    @StateObject private var viewModel: VirtualGardenViewModel

    public init() {
        _viewModel = StateObject(wrappedValue: VirtualGardenViewModel(
            userProfileRepository: CoreDataUserProfileRepository(coreDataStack: .shared)
        ))
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Garden view
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                    ForEach(viewModel.plants) { plant in
                        PlantCard(plant: plant)
                            .onTapGesture {
                                viewModel.selectPlant(plant)
                            }
                    }

                    // Empty slots
                    ForEach(0..<(6 - viewModel.plants.count), id: \.self) { _ in
                        EmptyPlantSlot()
                    }
                }
                .padding()
            }

            // Water button
            Button {
                Task {
                    await viewModel.waterGarden()
                }
            } label: {
                Label("Water Garden", systemImage: "drop.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding()
        }
        .task {
            await viewModel.loadGarden()
        }
        .sheet(item: $viewModel.selectedPlant) { plant in
            PlantDetailSheet(plant: plant)
        }
    }
}

// MARK: - Plant Card

struct PlantCard: View {
    let plant: Plant

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 100, height: 100)

                Text(plantIcon(for: plant))
                    .font(.system(size: 50))
            }

            VStack(spacing: 4) {
                Text(plant.name)
                    .font(.subheadline.bold())
                    .multilineTextAlignment(.center)

                HStack(spacing: 2) {
                    ForEach(0..<5) { stage in
                        Image(systemName: stage <= plant.growthStage ? "star.fill" : "star")
                            .font(.caption2)
                            .foregroundColor(stage <= plant.growthStage ? .yellow : .gray)
                    }
                }

                ProgressView(value: Double(plant.health))
                    .tint(.green)
                    .scaleEffect(0.8)
            }
        }
        .frame(height: 180)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(16)
    }

    private func plantIcon(for plant: Plant) -> String {
        switch plant.type {
        case .tree: return "🌳"
        case .flower: return "🌸"
        case .vine: return "🌿"
        case .bush: return "🌺"
        }
    }
}

// MARK: - Empty Plant Slot

struct EmptyPlantSlot: View {
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .foregroundColor(.secondary.opacity(0.3))
                    .frame(width: 100, height: 100)

                Image(systemName: "plus")
                    .font(.title)
                    .foregroundColor(.secondary.opacity(0.3))
            }

            Text("Empty Slot")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(height: 180)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(16)
    }
}

// MARK: - Plant Detail Sheet

struct PlantDetailSheet: View {
    let plant: Plant
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text(plantIcon(for: plant))
                        .font(.system(size: 100))

                    VStack(spacing: 8) {
                        Text(plant.name)
                            .font(.title.bold())

                        Text(plant.type.rawValue.capitalized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    // Growth progress
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Growth Stage")
                            .font(.headline)

                        HStack {
                            ForEach(0..<5) { stage in
                                VStack {
                                    Image(systemName: stage <= plant.growthStage ? "star.fill" : "star")
                                        .foregroundColor(stage <= plant.growthStage ? .yellow : .gray)

                                    Text("\(stage + 1)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(12)

                    // Health
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Health")
                            .font(.headline)

                        ProgressView(value: Double(plant.health))
                            .tint(.green)

                        Text("Last watered: \(plant.lastWatered.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Plant Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func plantIcon(for plant: Plant) -> String {
        switch plant.type {
        case .tree: return "🌳"
        case .flower: return "🌸"
        case .vine: return "🌿"
        case .bush: return "🌺"
        }
    }
}
