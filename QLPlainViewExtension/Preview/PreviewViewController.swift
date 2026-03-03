//
//  PreviewViewController.swift
//  QLPlainViewExtension
//
//  Created by neo on 2/28/26.
//
import Cocoa
import Quartz
import os

/// PreviewViewController is the main controller for the Quick Look extension.
/// It reads the file, detects encoding, applies syntax highlighting,
/// and renders the content in a scrollable text view.
class PreviewViewController: NSViewController, QLPreviewingController {
    
    // MARK: - Properties
    
    /// Default max file size (100KB) used when UserDefaults has no value set.
    /// This provides a safe fallback when user preferences are uninitialized.
    private let defaultMaxFileSize = 102400
    
    /// Reads max file size from UserDefaults, falls back to defaultMaxFileSize.
    /// Uses App Group UserDefaults if available for cross-target synchronization.
    private var maxFileSize: Int {
        let userInfo = Bundle.main.infoDictionary
        let hasAppGroup = userInfo?["AppGroups"] != nil
        
        if hasAppGroup, let appGroupContainer = UserDefaults(suiteName: "group.com.joshaken.QLPlainView") {
            let saved = appGroupContainer.integer(forKey: "maxFileSizeBytes")
            return saved > 0 ? saved : defaultMaxFileSize
        } else {
            let saved = UserDefaults.standard.integer(forKey: "maxFileSizeBytes")
            return saved > 0 ? saved : defaultMaxFileSize
        }
    }
    
    /// Weak reference to the scroll view to avoid retain cycles.
    /// Uses weak reference pattern to allow proper deallocation when not needed.
    private weak var scrollView: NSScrollView?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.autoresizingMask = [.width, .height]
    }
    
    // MARK: - QLPreviewingController
    
    /// Entry point called by QuickLook when a file needs to be previewed.
    /// Reads file data, checks encoding, applies highlighting, and renders the UI.
    /// 
    /// This method implements the core Quick Look workflow:
    /// 1. Validates and loads the file
    /// 2. Checks if file exceeds max size constraints
    /// 3. Detects encoding
    /// 4. Applies syntax highlighting
    /// 5. Renders in the scrollable preview window
    /// 
    /// - Parameters:
    ///   - url: The file URL to preview.
    ///   - completionHandler: Completion handler with error result or success flag.
    func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
        FileLogger.info("[Preview] Invoked")
        FileLogger.info("[Preview] File URL: \(url.path)")
        FileLogger.info("[Preview] File type: \(url.pathExtension)")
        
        FileLogger.info("Processing preview for: \(url.path)")
        
        // Read file data
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            FileLogger.error("Failed to read file: \(error.localizedDescription)")
            handler(error)
            return
        }
        
        // Truncate if file exceeds max size
        let isTruncated = data.count > maxFileSize
        let displayData = isTruncated ? data.prefix(maxFileSize) : Data(data)
        
        FileLogger.info("[Preview] Max file size: \(maxFileSize) bytes")
        FileLogger.info("[Preview] File size: \(data.count) bytes")
        
        // Reject binary files early
        if String.isBinaryContent(displayData) {
            FileLogger.info("[Preview] Unsupported file type")
            FileLogger.info("Skipping binary file: \(url.lastPathComponent)")
            handler(PreviewError.unsupportedEncoding)
            return
        }
        
        // Detect text encoding
        guard let content = detectAndDecode(data: displayData[...]) else {
            FileLogger.error("Failed to detect encoding for: \(url.lastPathComponent)")
            FileLogger.info("[Preview] Encoding detection failed")
            handler(PreviewError.unsupportedEncoding)
            return
        }
        
        let fileType = FileType.detect(from: url)
        
        FileLogger.info("[Preview] Supported: true")
        FileLogger.info("Supported file type detected: \(fileType), Size: \(data.count) bytes")
        
        // Update UI on main thread
        Task { @MainActor in
            self.clearViews()
            self.setupTextView(
                url: url,
                content: content,
                isTruncated: isTruncated,
                fileSize: data.count,
                fileType: fileType
            )
            handler(nil)
        }
    }
    
    // MARK: - Encoding Detection
    
    /// Attempts to decode data using common text encodings.
    /// Returns the first successfully decoded string, or nil if all fail.
    /// 
    /// Tries a prioritized list of encodings to handle various text formats:
    /// - utf8: Primary standard for most modern text files
    /// - ascii: Basic ASCII, often used for simple text
    /// - isoLatin1: Western European character sets
    /// - utf16: Unicode with byte order mark handling
    /// - japaneseEUC: Japanese text encoding (legacy support)
    /// - shiftJIS: Shift-JIS Japanese text encoding (legacy support)
    /// 
    /// - Parameter data: Data to decode.
    /// - Returns: The decoded string, or nil if all encodings fail.
    private func detectAndDecode(data: Data.SubSequence) -> String? {
        let encodings: [String.Encoding] = [
            .utf8, .ascii, .isoLatin1, .utf16, .japaneseEUC, .shiftJIS
        ]
        for encoding in encodings {
            if let text = String(data: Data(data), encoding: encoding) {
                FileLogger.debug("Detected encoding: \(encoding)")
                return text
            }
        }
        return nil
    }
    
    // MARK: - UI Setup
    
    /// Builds and displays the text content inside a scrollable view.
    /// Also configures the PreviewContentView with the file URL for the "Open With" button.
    /// 
    /// - Parameters:
    ///   - url: The file URL for reference and "Open With" functionality.
    ///   - content: The decoded text content to display.
    ///   - isTruncated: Whether the content was truncated due to size limits.
    ///   - fileSize: Original file size in bytes.
    ///   - fileType: The detected file type for syntax highlighting.
    private func setupTextView(
        url: URL,
        content: String,
        isTruncated: Bool,
        fileSize: Int,
        fileType: FileType
    ) {
        // Append truncation notice if file was too large
        var displayContent = content
        if isTruncated {
            displayContent += "\n\n--- file too big (\(fileSize / 1024)KB), only showing \(maxFileSize / 1024)KB ---"
            FileLogger.info("[Preview] Max file size exceeded: \(fileSize) bytes")
        }
        
        // Apply syntax highlighting based on file type
        let font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        let attributed = fileType.highlight(content: displayContent, font: font)
        
        // Wrap text view in scroll view
        let newScrollView = NSScrollView()
        newScrollView.hasVerticalScroller = true
        newScrollView.hasHorizontalScroller = true
        newScrollView.autohidesScrollers = true
        newScrollView.backgroundColor = NSColor.textBackgroundColor
        newScrollView.frame = view.bounds
        newScrollView.autoresizingMask = [.width, .height]
        
        // Configure text view (read-only, selectable for copy support)
        let textView = NSTextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = NSColor.textBackgroundColor
        textView.textColor = NSColor.textColor
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.frame = CGRect(x: 0, y: 0, width: newScrollView.contentSize.width, height: 0)
        textView.textContainer?.containerSize = CGSize(
            width: newScrollView.contentSize.width,
            height: .greatestFiniteMagnitude
        )
        textView.textContainer?.widthTracksTextView = true
        textView.textStorage?.setAttributedString(attributed)
        
        newScrollView.documentView = textView
        view.addSubview(newScrollView)
        self.scrollView = newScrollView
        
        DispatchQueue.main.async { [weak self] in
            self?.view.window?.makeFirstResponder(textView)
        }
        
        // Pass file URL and scroll view to PreviewContentView for "Open With" button
        if let contentView = view as? PreviewContentView {
            contentView.configure(with: url, scrollView: newScrollView)
        }
        
        FileLogger.info("Preview rendered: \(url.lastPathComponent) as \(fileType)")
    }
    
    /// Removes all subviews and releases the scroll view reference.
    /// Critical for memory management in Quick Look extensions which are often short-lived.
    private func clearViews() {
        if let scrollView = scrollView,
           let textView = scrollView.documentView as? NSTextView {
            textView.textStorage?.setAttributedString(NSAttributedString())
        }
        view.subviews.forEach { $0.removeFromSuperview() }
        scrollView = nil
    }
}

// MARK: - Error Type
enum PreviewError: Error {
    /// Error raised when file content cannot be decoded as text
    case unsupportedEncoding
}
