//
//  String+BinaryDetection.swift
//  QLPlainViewExtension
//
//  Created by neo on 3/1/26.
//

import Foundation

extension String {
    
    /// Determines if a data sample appears to contain binary content by analyzing the
    /// ratio of non-printable characters. This is a critical filter before attempting
    /// to render text-based content, as binary files can cause crashes or garbled output
    /// when passing through text rendering systems.
    /// 
    /// The detection uses a statistical approach that checks the first 1024 bytes of the
    /// data to determine if it's likely text or binary. Binary content typically contains
    /// a high proportion of non-printable characters including null bytes, control codes,
    /// or byte values below ASCII 32 (except common whitespace characters).
    /// 
    /// - Parameters:
    ///   - data: Data to analyze. Only the first 1024 bytes are examined.
    /// - Returns: `true` if the content is likely binary, `false` if it appears to be text.
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
