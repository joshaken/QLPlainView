//
//  FileType.swift
//  QLPlainViewExtension
//
//  Created by neo on 3/1/26.
//

import Cocoa

enum FileType {
    case yaml
    case lua
    case json
    case xml
    case plain
    
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
