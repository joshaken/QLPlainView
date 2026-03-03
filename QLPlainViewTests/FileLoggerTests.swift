//  FileLoggerTests.swift
//  QLPlainViewTests
//
//  Unit tests for FileLogger functionality and logging behavior.
//  Tests focus on log file operations, structure detection, and reliability.

import XCTest
@testable import QLPlainViewExtension

/// Unit tests for FileLogger.
/// Validates log file write, read, clear, and structured logging operations.
final class FileLoggerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        FileLogger.clearLogFile()
    }
    
    override func tearDown() {
        FileLogger.clearLogFile()
        super.tearDown()
    }
    
    // MARK: - Write Tests
    
    /// Verifies that an info message is written to the log file with the correct level marker.
    func testInfoLogWrite() {
        let message = "Test info message"
        FileLogger.info(message)
        
        let contents = FileLogger.readLogFile()
        XCTAssertTrue(contents.contains(message), "Log file should contain the info message")
        XCTAssertTrue(contents.contains("[INFO]"), "Log file should contain INFO level marker")
    }
    
    /// Verifies that an error message is written with the ERROR level marker.
    func testErrorLogWrite() {
        let message = "Test error message"
        FileLogger.error(message)
        
        let contents = FileLogger.readLogFile()
        XCTAssertTrue(contents.contains(message), "Log file should contain the error message")
        XCTAssertTrue(contents.contains("[ERROR]"), "Log file should contain ERROR level marker")
    }
    
    /// Verifies that a debug message is written with the DEBUG level marker.
    func testDebugLogWrite() {
        let message = "Test debug message"
        FileLogger.debug(message)
        
        let contents = FileLogger.readLogFile()
        XCTAssertTrue(contents.contains(message), "Log file should contain the debug message")
        XCTAssertTrue(contents.contains("[DEBUG]"), "Log file should contain DEBUG level marker")
    }
    
    /// Verifies that a warning message is written with the WARNING level marker.
    func testWarningLogWrite() {
        let message = "Test warning message"
        FileLogger.warning(message)
        
        let contents = FileLogger.readLogFile()
        XCTAssertTrue(contents.contains(message), "Log file should contain the warning message")
        XCTAssertTrue(contents.contains("[WARNING]"), "Log file should contain WARNING level marker")
    }
    
    // MARK: - Timestamp Tests
    
    /// Verifies that each log entry includes a properly formatted timestamp.
    func testLogEntryContainsTimestamp() {
        FileLogger.info("Timestamp test")
        
        let contents = FileLogger.readLogFile()
        
        // Match actual timestamp format: [2026-03-03 12:00:00]
        let pattern = #"\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\]"#
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(contents.startIndex..., in: contents)
        let matched = regex?.firstMatch(in: contents, range: range) != nil
        
        XCTAssertTrue(matched, "Log entry should contain a timestamp in [yyyy-MM-dd HH:mm:ss] format")
    }
    
    // MARK: - Line Count Tests
    
    /// Verifies that line count increments correctly with each log entry.
    func testLogLineCount() {
        XCTAssertEqual(FileLogger.logLineCount(), 0, "Empty log file should have 0 lines")
        
        FileLogger.info("Line 1")
        XCTAssertEqual(FileLogger.logLineCount(), 1, "Should have 1 line after first entry")
        
        FileLogger.info("Line 2")
        XCTAssertEqual(FileLogger.logLineCount(), 2, "Should have 2 lines after second entry")
        
        FileLogger.error("Line 3")
        XCTAssertEqual(FileLogger.logLineCount(), 3, "Should have 3 lines after third entry")
    }
    
    /// Verifies that multiple sequential writes all appear in the log file.
    func testMultipleSequentialWrites() {
        let count = 10
        for i in 1...count {
            FileLogger.info("Message \(i)")
        }
        
        let contents = FileLogger.readLogFile()
        let lineCount = contents
            .components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
            .count
        
        XCTAssertEqual(lineCount, count, "Should have \(count) log entries after \(count) writes")
        
        for i in 1...count {
            XCTAssertTrue(contents.contains("Message \(i)"), "Log should contain message \(i)")
        }
    }
    
    // MARK: - Clear Tests
    
    /// Verifies that clearLogFile removes all log entries.
    func testClearLogFile() {
        FileLogger.info("Entry before clear")
        FileLogger.error("Error before clear")
        XCTAssertGreaterThan(FileLogger.logLineCount(), 0, "Should have entries before clearing")
        
        let result = FileLogger.clearLogFile()
        XCTAssertTrue(result, "clearLogFile should return true on success")
        XCTAssertEqual(FileLogger.logLineCount(), 0, "Line count should be 0 after clearing")
        XCTAssertTrue(FileLogger.readLogFile().isEmpty, "Log contents should be empty after clearing")
    }
    
    /// Verifies that new entries can be written after the log file is cleared.
    func testWriteAfterClear() {
        FileLogger.info("Before clear")
        FileLogger.clearLogFile()
        
        FileLogger.info("After clear")
        let contents = FileLogger.readLogFile()
        
        XCTAssertFalse(contents.contains("Before clear"), "Should not contain entries from before clear")
        XCTAssertTrue(contents.contains("After clear"), "Should contain new entry written after clear")
    }
    
    // MARK: - Read Tests
    
    /// Verifies that reading the log file multiple times returns consistent results.
    func testReadLogFileMultipleTimes() {
        FileLogger.info("First message")
        let firstRead = FileLogger.readLogFile()
        
        FileLogger.info("Second message")
        let secondRead = FileLogger.readLogFile()
        
        XCTAssertTrue(firstRead.contains("First message"), "First read should contain first message")
        XCTAssertTrue(secondRead.contains("First message"), "Second read should still contain first message")
        XCTAssertTrue(secondRead.contains("Second message"), "Second read should contain second message")
        XCTAssertFalse(firstRead.contains("Second message"), "First read should not contain second message")
    }
    
    /// Verifies that readLogFile with maxLines limits the output correctly.
    func testReadLogFileWithMaxLines() {
        for i in 1...5 {
            FileLogger.info("Line \(i)")
        }
        
        let limited = FileLogger.readLogFile(maxLines: 3)
        let lineCount = limited
            .components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
            .count
        
        XCTAssertEqual(lineCount, 3, "readLogFile(maxLines: 3) should return exactly 3 lines")
    }
    
    // MARK: - Structured Logging Tests
    
    /// Verifies that structured logs contain the semantic prefix and message.
    func testStructuredLogging() {
        FileLogger.logStructured(prefix: "[Preview]", message: "Structured test message")
        
        let contents = FileLogger.readLogFile()
        XCTAssertTrue(contents.contains("[Preview]"), "Structured log should contain the prefix marker")
        XCTAssertTrue(contents.contains("Structured test message"), "Structured log should contain the message")
    }
    
    /// Verifies that multiple structured log markers are all written correctly.
    func testStructuredLoggingWithMultipleMarkers() {
        let markers = ["[Preview]", "[Settings]", "[Error]", "[Info]"]
        for marker in markers {
            FileLogger.logStructured(prefix: marker, message: "\(marker) test message")
        }
        
        let contents = FileLogger.readLogFile()
        for marker in markers {
            XCTAssertTrue(contents.contains(marker), "Log should contain marker: \(marker)")
        }
    }
    
    // MARK: - File Path Tests
    
    /// Verifies that the log file is stored at the expected path.
    func testLogFilePath() {
        let logURL = FileLogger.logURL
        XCTAssertEqual(logURL.lastPathComponent, "QLPlainView.log", "Log file should be named QLPlainView.log")
        XCTAssertTrue(logURL.path.contains("Library/Logs/QLPlainView"), "Log file should be in Library/Logs/QLPlainView")
    }
    
    // MARK: - Safety Tests
    
    /// Verifies that all logger methods execute without throwing or crashing.
    func testLoggerDoesNotCrash() {
        XCTAssertNoThrow(FileLogger.info("Safe info"))
        XCTAssertNoThrow(FileLogger.error("Safe error"))
        XCTAssertNoThrow(FileLogger.debug("Safe debug"))
        XCTAssertNoThrow(FileLogger.warning("Safe warning"))
        XCTAssertNoThrow(FileLogger.logStructured(prefix: "[Test]", message: "Safe structured"))
    }
}
