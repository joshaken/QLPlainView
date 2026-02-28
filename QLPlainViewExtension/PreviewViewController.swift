//
//  PreviewViewController.swift
//  QLPlainViewExtension
//
//  Created by neo on 2/28/26.
//

import Cocoa
import Quartz
import os

class PreviewViewController: NSViewController, QLPreviewingController {
    private let logger = Logger(
        subsystem: "com.joshaken.qlsimpdoc",
        category: "preview"
    )
    
    private let maxFileSize = 102400 // 100KB
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Ensure we're using a proper view with autoresizing masks
        view.autoresizingMask = [.width, .height]
    }
    
    func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
        do {
            // Read data
            let data = try Data(contentsOf: url)
            
            // Truncate big data
            let truncated = data.prefix(maxFileSize)
            let isTruncated = data.count > maxFileSize
            
            // Detect encoding
            guard let content = detectAndDecode(data: truncated) else {
                handler(PreviewError.unsupportedEncoding)
                return
            }
            
            // Get file extension
            let ext = url.pathExtension.lowercased()
            let isYaml = ["yaml", "yml"].contains(ext)
            
            // Set UI
            setupTextView(
                content: content,
                isTruncated: isTruncated,
                fileSize: data.count,
                isYaml: isYaml
            )
            
            handler(nil)
            
        } catch {
            logger.error("read file error: \(error.localizedDescription)")
            handler(error)
        }
    }
    
    // MARK: - Encoding Detection
    private func detectAndDecode(data: Data.SubSequence) -> String? {
        let encodings: [String.Encoding] = [
            .utf8,
            .ascii,
            .isoLatin1,
            .utf16,
            .japaneseEUC,
            .shiftJIS
        ]
        
        for encoding in encodings {
            if let text = String(data: Data(data), encoding: encoding) {
                logger.debug("Detected encoding: \(encoding)")
                return text
            }
        }
        return nil
    }
    
    // MARK: - UI Setup
    private func setupTextView(
        content: String,
        isTruncated: Bool,
        fileSize: Int,
        isYaml: Bool = false
    ) {
        // Clear existing views
        view.subviews.forEach { $0.removeFromSuperview() }
        
        // Create scroll view
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.backgroundColor = NSColor.textBackgroundColor
        
        // Create text view
        let textView = NSTextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.backgroundColor = NSColor.textBackgroundColor
        textView.textColor = NSColor.textColor
        
        // Handle truncated content
        var displayContent = content
        if isTruncated {
            let kb = fileSize / 1024
            displayContent += "\n\n--- file too big（\(kb)KB），only show 100KB ---"
        }
        
        // Apply YAML highlighting if needed
        if isYaml {
            let attributed = highlightYaml(content: displayContent)
            textView.textStorage?.setAttributedString(attributed)
        } else {
            textView.string = displayContent
        }
        
        // Set up scroll view
        scrollView.documentView = textView
        scrollView.frame = view.bounds
        scrollView.autoresizingMask = [.width, .height]
        
        // Add scroll view to main view
        view.addSubview(scrollView)
        
        
    }
    
    
    // MARK: - YAML Highlighting
    private func highlightYaml(content: String) -> NSAttributedString {
        let result = NSMutableAttributedString()
        let baseFont = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        
        for line in content.components(separatedBy: "\n") {
            let attributed: NSAttributedString
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            if trimmed.hasPrefix("#") {
                // comment → grey
                attributed = NSAttributedString(
                    string: line + "\n",
                    attributes: [
                        .foregroundColor: NSColor.systemGray,
                        .font: baseFont
                    ]
                )
            } else if trimmed.hasPrefix("-") {
                // list → orange
                attributed = NSAttributedString(
                    string: line + "\n",
                    attributes: [
                        .foregroundColor: NSColor.systemOrange,
                        .font: baseFont
                    ]
                )
            } else if line.contains(":") {
                // key: value → key blue, value origin
                if let colonIndex = line.firstIndex(of: ":") {
                    let key = String(line[line.startIndex...colonIndex])
                    let rest = String(line[line.index(after: colonIndex)...])
                    
                    let lineAttr = NSMutableAttributedString()
                    lineAttr.append(NSAttributedString(
                        string: key,
                        attributes: [
                            .foregroundColor: NSColor.systemBlue,
                            .font: baseFont
                        ]
                    ))
                    lineAttr.append(NSAttributedString(
                        string: rest + "\n",
                        attributes: [
                            .foregroundColor: NSColor.textColor,
                            .font: baseFont
                        ]
                    ))
                    attributed = lineAttr
                } else {
                    attributed = NSAttributedString(
                        string: line + "\n",
                        attributes: [
                            .foregroundColor: NSColor.textColor,
                            .font: baseFont
                        ]
                    )
                }
            } else {
                attributed = NSAttributedString(
                    string: line + "\n",
                    attributes: [
                        .foregroundColor: NSColor.textColor,
                        .font: baseFont
                    ]
                )
            }
            
            result.append(attributed)
        }
        
        return result
    }
}

// MARK: - Error Type
enum PreviewError: Error {
    case unsupportedEncoding
}
