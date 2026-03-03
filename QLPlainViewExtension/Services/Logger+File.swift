//
//  Logger+File.swift
//  QLPlainViewExtension
//
//  Created by neo on 3/1/26.
//

import Foundation
import os

/// FileLogger provides structured logging to both console and file.
/// Designed for Quick Look extensions which run in memory-limited environments.
/// All logs include timestamp, severity level, and semantic markers for grep detection.
struct FileLogger {
    
    /// ~/Library/Logs/QLPlainView/QLPlainView.log
    static let logURL: URL = {
        let logsDir = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Logs/QLPlainView")
        try? FileManager.default.createDirectory(at: logsDir, withIntermediateDirectories: true)
        return logsDir.appendingPathComponent("QLPlainView.log")
    }()
    
    /// Logs a message with the specified level.
    /// Includes timestamp, level, and message in a structured format.
    /// Safe for concurrent access and memory-efficient for extensions.
    ///
    /// - Parameters:
    ///   - message: The log message to record.
    ///   - level: The severity level (INFO, ERROR, DEBUG).
    static func log(_ message: String, level: String = "INFO") {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let timestamp = formatter.string(from: Date())
        let line = "[\(timestamp)] [\(level)] \(message)\n"
        
        guard let data = line.data(using: .utf8) else { return }
        
        FileLock.shared.lock()
        defer { FileLock.shared.unlock() }
        
        // Atomic write to prevent corruption
        if FileManager.default.fileExists(atPath: logURL.path){
            if let handle = try? FileHandle(forWritingTo: logURL) {
                handle.seekToEndOfFile()
                handle.write(data)
                handle.synchronizeFile()
                handle.closeFile()
            }
    
        } else {
            try? data.write(to: logURL, options: .atomic)
        }
    }
    
    /// Logs informational messages.
    /// Used for normal operation events and state changes.
    ///
    /// - Parameter message: The informational message to log.
    static func info(_ message: String)  { log(message, level: "INFO")  }
    
    /// Logs error messages.
    /// Used for failures, exceptions, or recoverable errors.
    ///
    /// - Parameter message: The error message to log.
    static func error(_ message: String) { log(message, level: "ERROR") }
    
    /// Logs debug messages.
    /// Used for diagnostic information during development.
    ///
    /// - Parameter message: The debug message to log.
    static func debug(_ message: String) { log(message, level: "DEBUG") }
    
    static func warning(_ message: String) { log(message, level: "WARNING") }
    
    /// Creates a structured log entry with semantic prefix markers.
    /// Enables grep detection of key events in log files.
    ///
    /// - Parameter prefix: Predefined semantic marker (e.g., "[Preview]", "[Settings]").
    /// - Parameter message: The message to log.
    static func logStructured(prefix: String, message: String, level: String = "INFO") {
        let structuredMessage = "\(prefix) \(message)"
        log(structuredMessage, level: level)
        Logger(subsystem: "com.joshaken.QLPlainView", category: "filelogger").info("[FileLogger] \(structuredMessage)")
    }
    
    /// Clears the log file.
    /// Useful for test cleanup and log rotation.
    ///
    /// - Returns: true if successful, false on error.
    @discardableResult
    static func clearLogFile() -> Bool {
        if FileManager.default.fileExists(atPath: logURL.path) {
            return (try? FileManager.default.removeItem(at: logURL)) != nil
        }
        return true
    }
    
    /// Reads the entire log file contents.
    /// Useful for testing and log analysis.
    ///
    /// - Parameter maxLines: Maximum number of lines to return (default: all).
    /// - Returns: The log file contents as a string, or empty string if not found/empty.
    static func readLogFile(maxLines: Int = Int.max) -> String {
        guard FileManager.default.fileExists(atPath: logURL.path) else { return "" }
        
        do {
            let contents = try String(contentsOf: logURL, encoding: .utf8)
            let lines = contents.components(separatedBy: .newlines)
            return lines.prefix(maxLines).joined(separator: "\n")
        } catch {
            FileLogger.error("Failed to read log file: \(error.localizedDescription)")
            return ""
        }
    }
    
    /// Returns the number of lines in the log file.
    /// Useful for monitoring and log rotation logic.
    ///
    /// - Returns: The line count, or 0 if the log file doesn't exist.
    static func logLineCount() -> Int {
        guard FileManager.default.fileExists(atPath: logURL.path) else { return 0 }
            
            do {
                let contents = try String(contentsOf: logURL, encoding: .utf8)
                return contents
                    .components(separatedBy: .newlines)
                    .filter { !$0.isEmpty } 
                    .count
            } catch {
                return 0
            }
    }
}

/// FileLock provides atomic file access for concurrent logging operations.
/// Prevents log corruption when multiple threads write simultaneously.
final class FileLock {
    static let shared = FileLock()
    private var unfairLock = os_unfair_lock_s()
    
    private init() {}
    
    func lock() {
        os_unfair_lock_lock(&unfairLock)
    }
    
    func unlock() {
        os_unfair_lock_unlock(&unfairLock)
    }
}
