//
//  Logger.swift
//  Noema
//
//  Created on January 18, 2025.
//

import Foundation
import OSLog

/// Privacy-preserving logging utility
public final class Logger {

    // MARK: - Log Levels

    public enum Level: String {
        case debug = "🔍 DEBUG"
        case info = "ℹ️ INFO"
        case warning = "⚠️ WARNING"
        case error = "❌ ERROR"
        case critical = "🔥 CRITICAL"
    }

    // MARK: - Log Categories

    public enum Category: String {
        case app = "App"
        case coreData = "CoreData"
        case services = "Services"
        case ui = "UI"
        case network = "Network"
        case ai = "AI"
        case encryption = "Encryption"
        case gamification = "Gamification"
        case sync = "Sync"
        case analytics = "Analytics"
    }

    // MARK: - Properties

    private let osLogger: os.Logger
    private let category: Category
    private let isDebugMode: Bool

    // MARK: - Static Loggers

    public static let app = Logger(category: .app)
    public static let coreData = Logger(category: .coreData)
    public static let services = Logger(category: .services)
    public static let ui = Logger(category: .ui)
    public static let network = Logger(category: .network)
    public static let ai = Logger(category: .ai)
    public static let encryption = Logger(category: .encryption)
    public static let gamification = Logger(category: .gamification)
    public static let sync = Logger(category: .sync)
    public static let analytics = Logger(category: .analytics)

    // MARK: - Initialization

    public init(category: Category, subsystem: String = "com.noema.app") {
        self.category = category
        self.osLogger = os.Logger(subsystem: subsystem, category: category.rawValue)

        #if DEBUG
        self.isDebugMode = true
        #else
        self.isDebugMode = false
        #endif
    }

    // MARK: - Logging Methods

    /// Log debug message (only in debug builds)
    public func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        log(level: .debug, message: message, file: file, function: function, line: line)
        #endif
    }

    /// Log info message
    public func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .info, message: message, file: file, function: function, line: line)
    }

    /// Log warning message
    public func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .warning, message: message, file: file, function: function, line: line)
    }

    /// Log error message
    public func error(_ message: String, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        var fullMessage = message
        if let error = error {
            fullMessage += " - Error: \(error.localizedDescription)"
        }
        log(level: .error, message: fullMessage, file: file, function: function, line: line)
    }

    /// Log critical message
    public func critical(_ message: String, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        var fullMessage = message
        if let error = error {
            fullMessage += " - Error: \(error.localizedDescription)"
        }
        log(level: .critical, message: fullMessage, file: file, function: function, line: line)
    }

    // MARK: - Private Methods

    private func log(level: Level, message: String, file: String, function: String, line: Int) {
        let fileName = (file as NSString).lastPathComponent
        let location = "[\(fileName):\(line)] \(function)"
        let formattedMessage = "\(level.rawValue) [\(category.rawValue)] \(location) - \(message)"

        // Privacy-preserving: Never log PII
        let sanitizedMessage = sanitize(message: formattedMessage)

        // Log to os.Logger
        switch level {
        case .debug:
            osLogger.debug("\(sanitizedMessage)")
        case .info:
            osLogger.info("\(sanitizedMessage)")
        case .warning:
            osLogger.warning("\(sanitizedMessage)")
        case .error:
            osLogger.error("\(sanitizedMessage)")
        case .critical:
            osLogger.critical("\(sanitizedMessage)")
        }

        // Also print to console in debug mode
        if isDebugMode {
            print(sanitizedMessage)
        }
    }

    /// Sanitize message to remove potential PII
    private func sanitize(message: String) -> String {
        var sanitized = message

        // Remove email addresses
        let emailRegex = try? NSRegularExpression(pattern: #"[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}"#)
        if let regex = emailRegex {
            sanitized = regex.stringByReplacingMatches(
                in: sanitized,
                range: NSRange(sanitized.startIndex..., in: sanitized),
                withTemplate: "[EMAIL_REDACTED]"
            )
        }

        // Remove phone numbers (simple pattern)
        let phoneRegex = try? NSRegularExpression(pattern: #"\b\d{3}[-.]?\d{3}[-.]?\d{4}\b"#)
        if let regex = phoneRegex {
            sanitized = regex.stringByReplacingMatches(
                in: sanitized,
                range: NSRange(sanitized.startIndex..., in: sanitized),
                withTemplate: "[PHONE_REDACTED]"
            )
        }

        // Remove UUIDs (to prevent tracking specific entities)
        let uuidRegex = try? NSRegularExpression(pattern: #"[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}"#)
        if let regex = uuidRegex {
            sanitized = regex.stringByReplacingMatches(
                in: sanitized,
                range: NSRange(sanitized.startIndex..., in: sanitized),
                withTemplate: "[UUID_REDACTED]"
            )
        }

        return sanitized
    }

    // MARK: - Performance Logging

    /// Measure and log execution time
    public func measure<T>(_ message: String, block: () throws -> T) rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try block()
        let timeElapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000 // Convert to ms

        debug("\(message) - Completed in \(String(format: "%.2f", timeElapsed))ms")

        return result
    }

    /// Measure and log async execution time
    public func measure<T>(_ message: String, block: () async throws -> T) async rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try await block()
        let timeElapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000 // Convert to ms

        debug("\(message) - Completed in \(String(format: "%.2f", timeElapsed))ms")

        return result
    }
}
