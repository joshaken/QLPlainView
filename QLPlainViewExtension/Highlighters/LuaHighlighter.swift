//
//  LuaHighlighter.swift
//  QLPlainViewExtension
//
//  Created by neo on 3/1/26.
//

import Cocoa

struct LuaHighlighter {
    
    private static let keywords = [
        "if", "then", "else", "elseif", "end", "do", "while", "for",
        "in", "repeat", "until", "return", "break", "function", "local",
        "nil", "true", "false", "and", "or", "not"
    ]
    
    private static let keywordRegexes: [(NSRegularExpression, NSColor)] = {
        keywords.compactMap { keyword in
            guard let regex = try? NSRegularExpression(pattern: "\\b\(keyword)\\b") else { return nil }
            return (regex, NSColor.systemPurple)
        }
    }()
    
    static func highlight(content: String, font: NSFont) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        for line in content.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            if trimmed.hasPrefix("--") {
                result.append((line + "\n").attributed(color: .systemGray, font: font))
                continue
            }
            
            let lineAttr = NSMutableAttributedString(
                string: line + "\n",
                attributes: [.foregroundColor: NSColor.textColor, .font: font]
            )
            
            let range = NSRange(lineAttr.string.startIndex..., in: lineAttr.string)
            for (regex, color) in keywordRegexes {
                for match in regex.matches(in: lineAttr.string, range: range) {
                    lineAttr.addAttribute(.foregroundColor, value: color, range: match.range)
                }
            }
            
            result.append(lineAttr)
        }
        return result
    }
}
