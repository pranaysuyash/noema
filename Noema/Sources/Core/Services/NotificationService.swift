//
//  NotificationService.swift
//  Noema
//
//  Created on January 18, 2025.
//

import Foundation
import UserNotifications

/// Service for managing local notifications
public final class NotificationService {
    public static let shared = NotificationService()

    private let notificationCenter = UNUserNotificationCenter.current()

    private init() {}

    // MARK: - Authorization

    public func requestAuthorization() async throws -> Bool {
        let settings = await notificationCenter.notificationSettings()

        if settings.authorizationStatus == .notDetermined {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            Logger.services.info("Notification authorization: \(granted)")
            return granted
        }

        return settings.authorizationStatus == .authorized
    }

    // MARK: - Schedule Notifications

    public func scheduleDailyReminder(at time: Date) async throws {
        // Cancel existing daily reminder
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["daily-reminder"])

        let content = UNMutableNotificationContent()
        content.title = "Time to Reflect"
        content.body = "Take a moment to capture your thoughts and emotions."
        content.sound = .default

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-reminder", content: content, trigger: trigger)

        try await notificationCenter.add(request)
        Logger.services.info("Daily reminder scheduled for \(time)")
    }

    public func scheduleStreakReminder() async throws {
        // Cancel existing streak reminder
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["streak-reminder"])

        let content = UNMutableNotificationContent()
        content.title = "Don't Break Your Streak!"
        content.body = "You haven't journaled today. Keep your streak alive!"
        content.sound = .default

        // Schedule for 8 PM if user hasn't journaled
        var components = DateComponents()
        components.hour = 20
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "streak-reminder", content: content, trigger: trigger)

        try await notificationCenter.add(request)
        Logger.services.info("Streak reminder scheduled")
    }

    public func scheduleAchievementNotification(achievement: Achievement) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Achievement Unlocked! 🏆"
        content.body = achievement.title ?? "You've unlocked a new achievement!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "achievement-\(achievement.id.uuidString)",
            content: content,
            trigger: trigger
        )

        try await notificationCenter.add(request)
        Logger.services.info("Achievement notification scheduled")
    }

    public func scheduleLevelUpNotification(level: Int) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Level Up! 🎉"
        content.body = "Congratulations! You've reached level \(level)!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "level-up-\(level)", content: content, trigger: trigger)

        try await notificationCenter.add(request)
        Logger.services.info("Level up notification scheduled")
    }

    // MARK: - Cancel Notifications

    public func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        Logger.services.info("All notifications cancelled")
    }

    public func cancelDailyReminder() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["daily-reminder"])
        Logger.services.info("Daily reminder cancelled")
    }
}
