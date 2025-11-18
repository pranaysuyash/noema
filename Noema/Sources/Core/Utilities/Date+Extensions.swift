import Foundation

// MARK: - Date Extensions

extension Date {

    /// Check if date is today
    public var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    /// Check if date is yesterday
    public var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    /// Check if date is in this week
    public var isThisWeek: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }

    /// Check if date is in this month
    public var isThisMonth: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month)
    }

    /// Get relative time string (e.g., "2 hours ago")
    public var relativeTimeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    /// Get short relative time (e.g., "2h ago")
    public var shortRelativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    /// Format as "Today at 3:30 PM" or "Yesterday at 2:15 PM" or "Jan 15 at 10:00 AM"
    public var smartFormatted: String {
        if isToday {
            return "Today at \(formatted(.dateTime.hour().minute()))"
        } else if isYesterday {
            return "Yesterday at \(formatted(.dateTime.hour().minute()))"
        } else if isThisWeek {
            return formatted(.dateTime.weekday().hour().minute())
        } else if isThisMonth {
            return formatted(.dateTime.month().day().hour().minute())
        } else {
            return formatted(.dateTime.month().day().year())
        }
    }

    /// Start of day
    public var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// End of day
    public var endOfDay: Date {
        Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self) ?? self
    }

    /// Start of week
    public var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }

    /// Start of month
    public var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }

    /// Add days
    public func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }

    /// Add months
    public func adding(months: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: months, to: self) ?? self
    }

    /// Days between dates
    public func daysBetween(_ other: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self.startOfDay, to: other.startOfDay)
        return abs(components.day ?? 0)
    }
}
