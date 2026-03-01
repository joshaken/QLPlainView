//
//  YAMLHighlighter.swift
//  QLPlainViewExtension
//
//  Created by neo on 3/1/26.
//

import Cocoa

struct YAMLHighlighter {
    
    static func highlight(content: String, font: NSFont) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        for line in content.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            if trimmed.hasPrefix("#") {
                result.append((line + "\n").attributed(color: .systemGray, font: font))
                
            } else if trimmed.hasPrefix("-") {
                result.append((line + "\n").attributed(color: .systemOrange, font: font))
                
            } else if line.contains(":"), let colonIndex = line.firstIndex(of: ":") {
                let key  = String(line[line.startIndex...colonIndex])
                let rest = String(line[line.index(after: colonIndex)...])
                let lineAttr = NSMutableAttributedString()
                lineAttr.append(key.attributed(color: .systemBlue, font: font))
                lineAttr.append((rest + "\n").attributed(color: .textColor, font: font))
                result.append(lineAttr)
                
            } else {
                result.append((line + "\n").attributed(color: .textColor, font: font))
            }
        }
        return result
    }
}
