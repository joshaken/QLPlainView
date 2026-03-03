//
//  XMLHighlighter.swift
//  QLPlainViewExtension
//
//  Created by neo on 3/1/26.
//

import Cocoa

/// XMLHighlighter provides syntax highlighting for XML content using regex-based tokenization.
/// Highlights tags in blue and XML comments in gray for easy readability.
struct XMLHighlighter {
    
    /// Regular expression for matching XML tags (<tag> or </tag>).
    /// Matches any characters between angle brackets, excluding nested tags.
    private static let tagRegex = try? NSRegularExpression(pattern: #"<[^>]+>"#)
    
    /// Regular expression for matching XML comments (<!-- comment -->).
    /// Matches content between comment delimiters.
    private static let commentRegex = try? NSRegularExpression(pattern: #"<!--.*?-->"#)
    
    /// Applies XML syntax highlighting to the provided content.
    /// Uses regex to identify tags and comments, applying appropriate coloring.
    /// 
    /// - Parameters:
    ///   - content: The XML text to highlight.
    ///   - font: The font to use for rendering.
    /// - Returns: An NSAttributedString with XML-specific highlighting applied to tags and comments.
    static func highlight(content: String, font: NSFont) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        for line in content.components(separatedBy: "\n") {
            let lineAttr = NSMutableAttributedString(
                string: line + "\n",
                attributes: [.foregroundColor: NSColor.textColor, .font: font]
            )
            
            let range = NSRange(lineAttr.string.startIndex..., in: lineAttr.string)
            
            // Highlight comments in gray first
            if let regex = commentRegex {
                for match in regex.matches(in: lineAttr.string, range: range) {
                    lineAttr.addAttribute(.foregroundColor, value: NSColor.systemGray, range: match.range)
                }
            }
            
            // Highlight regular tags in blue, excluding those inside comments
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
