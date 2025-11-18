import Foundation
import CoreData

// MARK: - Tag Model

/// User-created or AI-suggested tags for organization
@objc(Tag)
public class Tag: NSManagedObject, Identifiable {

    // MARK: - Identity

    @NSManaged public var id: UUID
    @NSManaged public var name: String

    // MARK: - Appearance

    @NSManaged public var color: String?
    @NSManaged public var icon: String?  // SF Symbol name

    // MARK: - Metadata

    @NSManaged public var isSystem: Bool  // System-generated vs user-created
    @NSManaged public var createdAt: Date
    @NSManaged public var usageCount: Int

    // MARK: - Relationships

    @NSManaged public var notes: Set<Note>

    // MARK: - Computed Properties

    public var displayName: String {
        name.capitalized
    }

    public var notesCount: Int {
        notes.count
    }

    public var colorHex: String {
        color ?? "#007AFF"  // Default iOS blue
    }

    public var sfSymbol: String {
        icon ?? "tag.fill"
    }

    // MARK: - Initialization

    public override func awakeFromInsert() {
        super.awakeFromInsert()

        id = UUID()
        name = ""
        isSystem = false
        createdAt = Date()
        usageCount = 0
        notes = Set()
    }

    // MARK: - Methods

    /// Increment usage count when tag is applied
    public func incrementUsage() {
        usageCount += 1
    }

    /// Decrement usage count when tag is removed
    public func decrementUsage() {
        usageCount = max(0, usageCount - 1)
    }
}

// MARK: - Folder Model

/// Hierarchical organization structure for notes
@objc(Folder)
public class Folder: NSManagedObject, Identifiable {

    // MARK: - Identity

    @NSManaged public var id: UUID
    @NSManaged public var name: String

    // MARK: - Hierarchy

    @NSManaged public var parent: Folder?
    @NSManaged public var subfolders: Set<Folder>

    // MARK: - Appearance

    @NSManaged public var color: String?
    @NSManaged public var icon: String?  // SF Symbol name

    // MARK: - Metadata

    @NSManaged public var createdAt: Date
    @NSManaged public var sortOrder: Int

    // MARK: - Relationships

    @NSManaged public var notes: Set<Note>

    // MARK: - Computed Properties

    public var displayName: String {
        name
    }

    public var notesCount: Int {
        notes.count
    }

    public var totalNotesCount: Int {
        // Count notes in this folder and all subfolders
        var count = notes.count
        for subfolder in subfolders {
            count += subfolder.totalNotesCount
        }
        return count
    }

    public var depth: Int {
        var level = 0
        var current = parent
        while current != nil {
            level += 1
            current = current?.parent
        }
        return level
    }

    public var path: String {
        // Build hierarchical path (e.g., "Work/Projects/Noema")
        var components: [String] = [name]
        var current = parent
        while let folder = current {
            components.insert(folder.name, at: 0)
            current = folder.parent
        }
        return components.joined(separator: "/")
    }

    public var colorHex: String {
        color ?? "#007AFF"
    }

    public var sfSymbol: String {
        icon ?? "folder.fill"
    }

    // MARK: - Initialization

    public override func awakeFromInsert() {
        super.awakeFromInsert()

        id = UUID()
        name = ""
        createdAt = Date()
        sortOrder = 0
        subfolders = Set()
        notes = Set()
    }

    // MARK: - Methods

    /// Add a subfolder
    public func addSubfolder(_ folder: Folder) {
        var current = subfolders
        current.insert(folder)
        subfolders = current
        folder.parent = self
    }

    /// Remove a subfolder
    public func removeSubfolder(_ folder: Folder) {
        var current = subfolders
        current.remove(folder)
        subfolders = current
        folder.parent = nil
    }

    /// Check if this folder contains another folder (directly or indirectly)
    public func contains(_ folder: Folder) -> Bool {
        if subfolders.contains(folder) {
            return true
        }
        for subfolder in subfolders {
            if subfolder.contains(folder) {
                return true
            }
        }
        return false
    }

    /// Get all descendant folders (recursive)
    public func allSubfolders() -> [Folder] {
        var all = Array(subfolders)
        for subfolder in subfolders {
            all.append(contentsOf: subfolder.allSubfolders())
        }
        return all
    }

    /// Move to a new parent folder
    public func move(to newParent: Folder?) {
        // Prevent circular references
        if let newParent = newParent, self.contains(newParent) {
            return
        }

        parent?.removeSubfolder(self)
        newParent?.addSubfolder(self)
    }
}

// MARK: - Predefined System Tags

public enum SystemTag: String, CaseIterable {
    case work
    case personal
    case ideas
    case goals
    case gratitude
    case reflection
    case meeting
    case project
    case health
    case creativity

    public var displayName: String {
        rawValue.capitalized
    }

    public var color: String {
        switch self {
        case .work: return "#007AFF"
        case .personal: return "#FF9500"
        case .ideas: return "#FFCC00"
        case .goals: return "#34C759"
        case .gratitude: return "#FF2D55"
        case .reflection: return "#AF52DE"
        case .meeting: return "#5856D6"
        case .project: return "#00C7BE"
        case .health: return "#FF3B30"
        case .creativity: return "#FF2D55"
        }
    }

    public var icon: String {
        switch self {
        case .work: return "briefcase.fill"
        case .personal: return "person.fill"
        case .ideas: return "lightbulb.fill"
        case .goals: return "target"
        case .gratitude: return "heart.fill"
        case .reflection: return "sparkles"
        case .meeting: return "person.3.fill"
        case .project: return "folder.fill"
        case .health: return "heart.text.square.fill"
        case .creativity: return "paintpalette.fill"
        }
    }
}
