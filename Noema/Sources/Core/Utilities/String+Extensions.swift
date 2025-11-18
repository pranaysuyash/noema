import Foundation

// MARK: - String Extensions

extension String {

    /// Remove extra whitespace
    public var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Check if string is empty or only whitespace
    public var isBlank: Bool {
        trimmed.isEmpty
    }

    /// Word count
    public var wordCount: Int {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.count
    }

    /// Character count (excluding whitespace)
    public var characterCountExcludingSpaces: Int {
        filter { !$0.isWhitespace }.count
    }

    /// Truncate to length with ellipsis
    public func truncated(to length: Int, trailing: String = "...") -> String {
        guard self.count > length else { return self }
        return String(self.prefix(length)) + trailing
    }

    /// Extract first sentence
    public var firstSentence: String {
        let components = self.components(separatedBy: ". ")
        return components.first ?? self
    }

    /// Extract first N words
    public func firstWords(_ count: Int) -> String {
        let words = self.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        return words.prefix(count).joined(separator: " ")
    }

    /// Capitalize first letter only
    public var capitalizedFirst: String {
        guard let first = first else { return self }
        return first.uppercased() + dropFirst()
    }

    /// Check if contains any of the strings
    public func containsAny(of strings: [String], caseSensitive: Bool = false) -> Bool {
        strings.contains { contains($0, caseSensitive: caseSensitive) }
    }

    /// Check if contains string (with optional case sensitivity)
    public func contains(_ string: String, caseSensitive: Bool) -> Bool {
        if caseSensitive {
            return self.contains(string)
        } else {
            return self.lowercased().contains(string.lowercased())
        }
    }

    /// Extract mentions (@username)
    public var mentions: [String] {
        let pattern = "@[a-zA-Z0-9_]+"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }

        let matches = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
        return matches.compactMap {
            Range($0.range, in: self).map { String(self[$0]) }
        }
    }

    /// Extract hashtags (#tag)
    public var hashtags: [String] {
        let pattern = "#[a-zA-Z0-9_]+"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }

        let matches = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
        return matches.compactMap {
            Range($0.range, in: self).map { String(self[$0]) }
        }
    }

    /// Markdown to plain text
    public var plainText: String {
        // Simple markdown removal
        var text = self
        text = text.replacingOccurrences(of: "**", with: "")
        text = text.replacingOccurrences(of: "*", with: "")
        text = text.replacingOccurrences(of: "__", with: "")
        text = text.replacingOccurrences(of: "_", with: "")
        return text
    }
}
