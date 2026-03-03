//
//  SettingsStore.swift
//  QLPlainView
//
//  Created by neo on 3/3/26.
//

import Foundation

final class SettingsStore {
    
    static let shared = SettingsStore()
    
    private let key = "maxFileSizeBytes"
    private let defaultValue = 102400
    private let extensionBundleID = "com.joshaken.QLPlainView.QLPlainViewExtension"
    
    // MARK: - Read
    
    var maxFileSize: Int {
        readFromExtensionDefaults() ?? defaultValue
    }
    
    // MARK: - Write
    
    @discardableResult
    func save(bytes: Int) -> Bool {
        guard bytes > 0 else { return false }
        return writeToExtensionDefaults(bytes: bytes)
    }
    
    func reset() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
        process.arguments = ["delete", extensionBundleID, key]
        try? process.run()
        process.waitUntilExit()
    }
    
    // MARK: - Helpers
    
    private func readFromExtensionDefaults() -> Int? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
        process.arguments = ["read", extensionBundleID, key]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()
        
        try? process.run()
        process.waitUntilExit()
        
        guard process.terminationStatus == 0 else { return nil }
        
        let output = String(
            data: pipe.fileHandleForReading.readDataToEndOfFile(),
            encoding: .utf8
        )?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        return Int(output)
    }
    
    @discardableResult
    private func writeToExtensionDefaults(bytes: Int) -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
        process.arguments = ["write", extensionBundleID, key, "-int", "\(bytes)"]
        try? process.run()
        process.waitUntilExit()
        return process.terminationStatus == 0
    }
}
