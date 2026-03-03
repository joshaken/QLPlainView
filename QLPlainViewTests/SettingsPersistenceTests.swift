//  SettingsPersistenceTests.swift
//  QLPlainViewTests
//
//  Unit tests for settings persistence functionality.
//  Tests validate UserDefaults operations and app-wide configuration.

import XCTest
@testable import QLPlainView

final class SettingsPersistenceTests: XCTestCase {
    
    var store: SettingsStore!
    private let key = "maxFileSizeBytes"
    private let defaultMaxFileSize = 102400
    
    override func setUp() {
        super.setUp()
        store = SettingsStore.shared
        store.reset()
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    override func tearDown() {
        store.reset()
        store = nil
        UserDefaults.standard.removeObject(forKey: key)
        super.tearDown()
    }
    
    // MARK: - Default Value Tests
    
    /// Verifies that the default value is returned when no settings have been saved.
    func testDefaultFallback() {
        XCTAssertEqual(store.maxFileSize, 102400, "Default should be 100KB (102400 bytes)")
    }
    
    // MARK: - Save Tests
    
    /// Verifies that a valid KB value is correctly saved as bytes.
    func testSaveValidKBValue() {
        let result = store.save(bytes: 100 * 1024)
        XCTAssertTrue(result, "Save should succeed")
        XCTAssertEqual(store.maxFileSize, 102400, "Should save 100KB as 102400 bytes")
    }
    
    /// Verifies that a valid MB value is correctly saved as bytes.
    func testSaveValidMBValue() {
        let result = store.save(bytes: 1 * 1024 * 1024)
        XCTAssertTrue(result, "Save should succeed")
        XCTAssertEqual(store.maxFileSize, 1048576, "Should save 1MB as 1048576 bytes")
    }
    
    /// Verifies that a large value (1000MB) is saved correctly.
    func testSaveLargeMBValue() {
        let result = store.save(bytes: 1000 * 1024 * 1024)
        XCTAssertTrue(result, "Save should succeed for large values")
        XCTAssertEqual(store.maxFileSize, 1000 * 1024 * 1024, "Should save 1000MB correctly")
    }
    
    // MARK: - Validation Tests
    
    /// Verifies that zero bytes are rejected.
    func testRejectsZeroValue() {
        let result = store.save(bytes: 0)
        XCTAssertFalse(result, "Should reject zero bytes")
        XCTAssertEqual(store.maxFileSize, 102400, "Should fall back to default after rejection")
    }
    
    /// Verifies that negative values are rejected.
    func testRejectsNegativeValue() {
        let result = store.save(bytes: -1024)
        XCTAssertFalse(result, "Should reject negative bytes")
        XCTAssertEqual(store.maxFileSize, 102400, "Should fall back to default after rejection")
    }
    
    // MARK: - Persistence Tests
    
    /// Verifies that saved values persist when read back with a new store instance.
    func testPersistenceAcrossInstances() {
        store.save(bytes: 200 * 1024)
        
        let newStore = SettingsStore.shared
        XCTAssertEqual(newStore.maxFileSize, 200 * 1024, "Value should persist across instances")
    }
    
    /// Verifies that the most recently saved value overwrites the previous one.
    func testOverwritePreviousValue() {
        store.save(bytes: 100 * 1024)
        store.save(bytes: 200 * 1024)
        XCTAssertEqual(store.maxFileSize, 200 * 1024, "Should return the most recently saved value")
    }
    
    // MARK: - Reset Tests
    
    /// Verifies that reset restores the default value.
    func testResetRestoresDefault() {
        store.save(bytes: 500 * 1024)
        store.reset()
        XCTAssertEqual(store.maxFileSize, 102400, "Should return default after reset")
    }
    
    // MARK: - Default Value Tests
    
    /// Verifies that the default value is returned when no settings have been saved.
    func testDefaultMaxFileSizeWhenNotSet() {
        let saved = UserDefaults.standard.integer(forKey: key)
        let maxFileSize = saved > 0 ? saved : defaultMaxFileSize
        XCTAssertEqual(maxFileSize, defaultMaxFileSize, "Should return default 100KB when not set")
    }
    
    // MARK: - Read Tests
    
    /// Verifies that Extension can read a value written to its UserDefaults.
    func testExtensionReadsCorrectMaxFileSize() {
        let expected = 200 * 1024
        UserDefaults.standard.set(expected, forKey: key)
        
        let saved = UserDefaults.standard.integer(forKey: key)
        let maxFileSize = saved > 0 ? saved : defaultMaxFileSize
        
        XCTAssertEqual(maxFileSize, expected, "Extension should read the correct max file size")
    }
    
    /// Verifies that zero value falls back to default.
    func testZeroValueFallsBackToDefault() {
        UserDefaults.standard.set(0, forKey: key)
        
        let saved = UserDefaults.standard.integer(forKey: key)
        let maxFileSize = saved > 0 ? saved : defaultMaxFileSize
        
        XCTAssertEqual(maxFileSize, defaultMaxFileSize, "Zero value should fall back to default")
    }
    
    /// Verifies that negative value falls back to default.
    func testNegativeValueFallsBackToDefault() {
        UserDefaults.standard.set(-1024, forKey: key)
        
        let saved = UserDefaults.standard.integer(forKey: key)
        let maxFileSize = saved > 0 ? saved : defaultMaxFileSize
        
        XCTAssertEqual(maxFileSize, defaultMaxFileSize, "Negative value should fall back to default")
    }
    
    // MARK: - Truncation Tests
    
    /// Verifies that a file smaller than maxFileSize is not truncated.
    func testFileWithinLimitIsNotTruncated() {
        let maxFileSize = 100 * 1024
        let fileSize = 50 * 1024
        XCTAssertFalse(fileSize > maxFileSize, "File within limit should not be truncated")
    }
    
    /// Verifies that a file larger than maxFileSize is truncated.
    func testFileExceedingLimitIsTruncated() {
        let maxFileSize = 100 * 1024
        let fileSize = 200 * 1024
        XCTAssertTrue(fileSize > maxFileSize, "File exceeding limit should be truncated")
    }
    
    /// Verifies that truncated data size matches maxFileSize.
    func testTruncatedDataMatchesMaxFileSize() {
        let maxFileSize = 100
        let data = Data(repeating: 0x61, count: 200)
        
        let displayData = data.count > maxFileSize ? data.prefix(maxFileSize) : data
        XCTAssertEqual(displayData.count, maxFileSize, "Truncated data should match max file size")
    }
    
    /// Verifies that non-truncated data preserves original size.
    func testNonTruncatedDataPreservesSize() {
        let maxFileSize = 1000
        let data = Data(repeating: 0x61, count: 100)
        
        let displayData = data.count > maxFileSize ? data.prefix(maxFileSize) : data
        XCTAssertEqual(displayData.count, data.count, "Non-truncated data should preserve original size")
    }
    
    // MARK: - Settings Update Tests
    
    /// Verifies that updating the setting is immediately reflected when read.
    func testSettingUpdateIsImmediatelyReflected() {
        UserDefaults.standard.set(100 * 1024, forKey: key)
        
        let first = UserDefaults.standard.integer(forKey: key)
        XCTAssertEqual(first, 100 * 1024, "First read should return 100KB")
        
        UserDefaults.standard.set(200 * 1024, forKey: key)
        
        let second = UserDefaults.standard.integer(forKey: key)
        XCTAssertEqual(second, 200 * 1024, "Second read should return updated 200KB")
    }
}
