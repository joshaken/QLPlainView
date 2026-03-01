//
//  Logger+File.swift
//  QLPlainViewExtension
//
//  Created by neo on 3/1/26.
//

import Foundation
import os

struct FileLogger {
    
    // ~/Library/Logs/QLPlainView/QLPlainView.log
    static let logURL: URL = {
        let logsDir = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Logs/QLPlainView")
        try? FileManager.default.createDirectory(at: logsDir, withIntermediateDirectories: true)
        return logsDir.appendingPathComponent("QLPlainView.log")
    }()
    
    static func log(_ message: String, level: String = "INFO") {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timestamp = formatter.string(from: Date())
        let line = "[\(timestamp)] [\(level)] \(message)\n"
        
        if let data = line.data(using: .utf8) {
            if FileManager.default.fileExists(atPath: logURL.path) {
                // apend
                if let handle = try? FileHandle(forWritingTo: logURL) {
                    handle.seekToEndOfFile()
                    handle.write(data)
                    handle.closeFile()
                }
            } else {
                // new file
                try? data.write(to: logURL, options: .atomic)
            }
        }
    }
    
    static func info(_ message: String)  { log(message, level: "INFO")  }
    static func error(_ message: String) { log(message, level: "ERROR") }
    static func debug(_ message: String) { log(message, level: "DEBUG") }
}
