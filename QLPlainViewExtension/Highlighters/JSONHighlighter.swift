//
//  JSONHighlighter.swift
//  QLPlainViewExtension
//
//  Created by neo on 3/1/26.
//

import Cocoa

struct JSONHighlighter {
    
    private static let keyRegex = try? NSRegularExpression(pattern: #""([^"]+)"(\s*:)"#)
    
    static func highlight(content: String, font: NSFont) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        for line in content.components(separatedBy: "\n") {
            let lineAttr = NSMutableAttributedString(
                string: line + "\n",
                attributes: [.foregroundColor: NSColor.textColor, .font: font]
            )
            
            guard let regex = keyRegex else {
                result.append(lineAttr)
                continue
            }
            
            let range = NSRange(lineAttr.string.startIndex..., in: lineAttr.string)
            for match in regex.matches(in: lineAttr.string, range: range) {
                if match.numberOfRanges > 1 {
                    lineAttr.addAttribute(.foregroundColor, value: NSColor.systemBlue, range: match.range(at: 1))
                }
                if match.numberOfRanges > 2 {
                    lineAttr.addAttribute(.foregroundColor, value: NSColor.systemGreen, range: match.range(at: 2))
                }
            }
            result.append(lineAttr)
        }
        return result
    }
}
