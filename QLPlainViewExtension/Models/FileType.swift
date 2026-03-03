//
//  FileType.swift
//  QLPlainViewExtension
//
//  Created by neo on 3/1/26.
//

import Cocoa

/// File type enumeration representing supported file formats for syntax highlighting.
/// Determines the appropriate syntax highlighting rules based on file extension.
enum FileType {
    case yaml
    case lua
    case json
    case xml
    case plain
    
    /// Detects the file type by examining the URL's file extension.
    /// Handles case-insensitive extension matching.
    ///
    /// - Parameter url: The URL of the file to analyze.
    /// - Returns: The corresponding FileType enum case.
    static func detect(from url: URL) -> FileType {
        switch url.pathExtension.lowercased() {
        case "yaml", "yml":
            return .yaml
        case "lua":
            return .lua
        case "json":
            return .json
        case "xml":
            return .xml
        default:
            return .plain
        }
    }
    
    /// Applies syntax highlighting to the provided content based on the file type.
    /// Delegates to specific highlighter implementations or returns plain text.
    ///
    /// - Parameters:
    ///   - content: The text content to highlight.
    ///   - font: The font to use for rendering.
    /// - Returns: An NSAttributedString with appropriate syntax highlighting applied.
    func highlight(content: String, font: NSFont) -> NSAttributedString {
        switch self {
        case .yaml:
            return YAMLHighlighter.highlight(content: content, font: font)
        case .lua:
            return LuaHighlighter.highlight(content: content, font: font)
        case .json:
            return JSONHighlighter.highlight(content: content, font: font)
        case .xml:
            return XMLHighlighter.highlight(content: content, font: font)
        case .plain:
            return NSAttributedString(
                string: content,
                attributes: [.foregroundColor: NSColor.textColor, .font: font]
            )
        }
    }
}

extension FileType: Equatable {}
