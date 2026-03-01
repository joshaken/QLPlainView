//
//  String+BinaryDetection.swift
//  QLPlainViewExtension
//
//  Created by neo on 3/1/26.
//

import Foundation

extension String {
    /// Determines if data is binary by checking the ratio of non-printable characters
        /// - Parameter data: Data to check (checks first 1024 bytes)
        /// - Returns: true if content appears to be binary
        static func isBinaryContent(_ data: some DataProtocol) -> Bool {
            let maxBytesToCheck = 1024
            let bytes = Array(data.prefix(maxBytesToCheck))
            
            guard !bytes.isEmpty else { return false }
            
            // Null byte is a strong indicator of binary content
            if bytes.contains(0) { return true }
            
            // Count non-printable characters (excluding common whitespace)
            let nonPrintableCount = bytes.filter { byte in
                byte < 32 && byte != 10  // LF
                          && byte != 13  // CR
                          && byte != 9   // Tab
            }.count
            
            // If more than 5% are non-printable, treat as binary
            return Double(nonPrintableCount) / Double(bytes.count) > 0.05
        }
}
