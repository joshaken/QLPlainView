//  SettingsPersistenceTests.swift
//  QLPlainViewTests
//
//  Unit tests for settings persistence functionality.
//  Tests validate UserDefaults operations and app-wide configuration.

import XCTest
@testable import QLPlainView

final class SettingsPersistenceTests: XCTestCase {
    
    var store: SettingsStore!
    
    override func setUp() {
        super.setUp()
        store = SettingsStore.shared
        store.reset()
    }
    
    override func tearDown() {
        store.reset()
        store = nil
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
}
