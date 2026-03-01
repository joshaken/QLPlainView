//
//  XMLHighlighter.swift
//  QLPlainViewExtension
//
//  Created by neo on 3/1/26.
//

import Cocoa

struct XMLHighlighter {
    
    private static let tagRegex = try? NSRegularExpression(pattern: #"<[^>]+>"#)
    private static let commentRegex = try? NSRegularExpression(pattern: #"<!--.*?-->"#)
    
    static func highlight(content: String, font: NSFont) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        for line in content.components(separatedBy: "\n") {
            let lineAttr = NSMutableAttributedString(
                string: line + "\n",
                attributes: [.foregroundColor: NSColor.textColor, .font: font]
            )
            
            let range = NSRange(lineAttr.string.startIndex..., in: lineAttr.string)
            
            if let regex = commentRegex {
                for match in regex.matches(in: lineAttr.string, range: range) {
                    lineAttr.addAttribute(.foregroundColor, value: NSColor.systemGray, range: match.range)
                }
            }
            
            // tag → blue
            if let regex = tagRegex {
                for match in regex.matches(in: lineAttr.string, range: range) {
                    let isInsideComment = lineAttr.attribute(
                        .foregroundColor,
                        at: match.range.location,
                        effectiveRange: nil
                    ) as? NSColor == NSColor.systemGray
                    
                    if !isInsideComment {
                        lineAttr.addAttribute(.foregroundColor, value: NSColor.systemBlue, range: match.range)
                    }
                }
            }
            
            result.append(lineAttr)
        }
        return result
    }
}
