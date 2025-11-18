import SwiftUI

/// ViewModel for virtual garden screen
/// Shows user's garden with plants that grow based on activity
@MainActor
public final class VirtualGardenViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published public var garden: Garden?
    @Published public var plants: [Plant] = []
    @Published public var isLoading: Bool = false
    @Published public var error: Error?
    @Published public var availableSeeds: [Seed] = []
    @Published public var selectedPlant: Plant?

    // MARK: - Dependencies

    private let userProfileRepository: UserProfileRepositoryProtocol

    // MARK: - Initialization

    public init(userProfileRepository: UserProfileRepositoryProtocol) {
        self.userProfileRepository = userProfileRepository
    }

    // MARK: - Public Methods

    public func loadGarden() async {
        isLoading = true
        error = nil

        do {
            let profile = try await userProfileRepository.fetch()

            // TODO: Load actual garden data from repository
            // For now, generate based on user stats
            garden = Garden(
                id: UUID(),
                userId: profile?.id ?? UUID(),
                createdAt: Date(),
                lastWatered: Date()
            )

            await generatePlants(from: profile)
            generateAvailableSeeds()
        } catch {
            self.error = error
        }

        isLoading = false
    }

    public func refresh() async {
        await loadGarden()
    }

    public func selectPlant(_ plant: Plant) {
        selectedPlant = plant
    }

    public func deselectPlant() {
        selectedPlant = nil
    }

    public func plantSeed(_ seed: Seed) async {
        // TODO: Implement seed planting
        print("Planting seed: \(seed.name)")
    }

    public func waterGarden() async {
        // TODO: Implement garden watering
        garden?.lastWatered = Date()
    }

    // MARK: - Private Methods

    private func generatePlants(from profile: UserProfile?) async {
        guard let profile = profile else { return }

        var generatedPlants: [Plant] = []

        // Plant 1: Note-taking tree (grows with total notes)
        if profile.totalNotes > 0 {
            let growthStage = calculateGrowthStage(
                current: profile.totalNotes,
                stages: [0, 10, 50, 100, 500]
            )
            generatedPlants.append(Plant(
                id: UUID(),
                type: .tree,
                name: "Knowledge Tree",
                growthStage: growthStage,
                lastWatered: Date(),
                health: 1.0
            ))
        }

        // Plant 2: Streak flower (grows with streak)
        if profile.streak > 0 {
            let growthStage = calculateGrowthStage(
                current: profile.streak,
                stages: [0, 7, 30, 90, 365]
            )
            generatedPlants.append(Plant(
                id: UUID(),
                type: .flower,
                name: "Consistency Bloom",
                growthStage: growthStage,
                lastWatered: Date(),
                health: 1.0
            ))
        }

        // Plant 3: Experience vine (grows with level)
        if profile.level > 1 {
            let growthStage = calculateGrowthStage(
                current: profile.level,
                stages: [0, 5, 10, 25, 50]
            )
            generatedPlants.append(Plant(
                id: UUID(),
                type: .vine,
                name: "Growth Vine",
                growthStage: growthStage,
                lastWatered: Date(),
                health: 1.0
            ))
        }

        plants = generatedPlants
    }

    private func generateAvailableSeeds() {
        availableSeeds = [
            Seed(name: "Mindfulness Lotus", type: .flower, requiredLevel: 5),
            Seed(name: "Reflection Bamboo", type: .tree, requiredLevel: 10),
            Seed(name: "Insight Ivy", type: .vine, requiredLevel: 15),
            Seed(name: "Serenity Sakura", type: .tree, requiredLevel: 20)
        ]
    }

    private func calculateGrowthStage(current: Int, stages: [Int]) -> Int {
        for (index, stage) in stages.enumerated() {
            if current < stage {
                return max(0, index - 1)
            }
        }
        return stages.count - 1
    }
}

// MARK: - Garden

public struct Garden: Identifiable {
    public let id: UUID
    public let userId: UUID
    public let createdAt: Date
    public var lastWatered: Date
}

// MARK: - Plant

public struct Plant: Identifiable {
    public let id: UUID
    public let type: PlantType
    public let name: String
    public let growthStage: Int  // 0-4
    public let lastWatered: Date
    public let health: Float  // 0.0-1.0

    public enum PlantType {
        case tree
        case flower
        case vine
        case bush
    }
}

// MARK: - Seed

public struct Seed: Identifiable {
    public let id = UUID()
    public let name: String
    public let type: Plant.PlantType
    public let requiredLevel: Int
}
