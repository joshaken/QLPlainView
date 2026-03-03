//
//  PreviewContentView.swift
//  QLPlainViewExtension
//
//  Created by neo on 3/1/26.
//
import Cocoa

/// PreviewContentView is a custom NSView that displays file content in a scrollable text area.
/// It also provides an "Open With" button in the top-right corner that prioritizes Sublime Text,
/// falling back to the system default app if Sublime Text is not installed.
class PreviewContentView: NSView {
    
    // MARK: - Properties
    
    /// Weak reference to the scroll view containing the text content.
    /// The weak reference prevents retain cycles by allowing the scroll view to be deallocated
    /// even if this view holds a strong reference to it.
    private weak var scrollView: NSScrollView?
    
    /// Weak reference to the "Open With" button.
    /// Weak reference prevents strong cycle between this view and its button.
    private weak var openButton: NSButton?
    
    /// The file URL currently being previewed, used when opening externally.
    /// Stored to retrieve when user clicks "Open With" button.
    private var currentFileURL: URL?
    
    // MARK: - Init
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    
    /// Configure the view's basic layout behavior.
    /// Autoresizing masks ensure the view maintains proper relationships with its superview.
    private func setupView() {
        autoresizingMask = [.width, .height]
    }
    
    /// Called when the view is added to the view hierarchy.
    /// NSView uses viewDidMoveToWindow instead of didMoveToSuperview (UIKit-specific).
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        guard window != nil else { return }
        setupOpenButton()
    }
    
    /// Creates and positions the "Open With" button in the top-right corner.
    /// The button title reflects whether Sublime Text is installed.
    private func setupOpenButton() {
        // Avoid adding duplicate buttons if called multiple times
        guard openButton == nil else { return }
        
        let button = NSButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.title = hasSublimeText ? "Open in Sublime Text" : "Open in Default App"
        button.bezelStyle = .rounded
        button.target = self
        button.action = #selector(openButtonTapped)
        
        addSubview(button)
        self.openButton = button
        
        // Pin button to top-right corner with 8pt padding
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])
    }
    
    // MARK: - Public Interface
    
    /// Sets the file URL and scroll view reference.
    /// Call this from PreviewViewController after content is loaded.
    /// 
    /// - Parameters:
    ///   - url: The file URL to open externally.
    ///   - scrollView: The scroll view containing the preview content.
    func configure(with url: URL, scrollView: NSScrollView) {
        self.currentFileURL = url
        self.scrollView = scrollView
    }
    
    // MARK: - Actions
    
    /// Handles the "Open With" button tap.
    /// Opens the file in Sublime Text if available, otherwise uses the system default app.
    @objc private func openButtonTapped() {
        guard let fileURL = currentFileURL else {
            FileLogger.error("No file URL set for open action")
            return
        }
        
        if hasSublimeText, let sublimeURL = sublimeTextURL {
            // Open with Sublime Text
            NSWorkspace.shared.open(
                [fileURL],
                withApplicationAt: sublimeURL,
                configuration: .init()
            ) { _, error in
                if let error = error {
                    FileLogger.error("Failed to open in Sublime Text: \(error.localizedDescription)")
                    // Fall back to default app if Sublime Text launch fails
                    NSWorkspace.shared.open(fileURL)
                } else {
                    FileLogger.info("Opened \(fileURL.lastPathComponent) in Sublime Text")
                }
            }
        } else {
            // Open with system default app
            NSWorkspace.shared.open(fileURL)
            FileLogger.info("Opened \(fileURL.lastPathComponent) with default app")
        }
    }
    
    // MARK: - Sublime Text Detection
    
    /// Returns true if any version of Sublime Text is installed.
    /// Checked to determine button title and open-with behavior.
    private var hasSublimeText: Bool {
        sublimeTextURL != nil
    }
    
    /// Returns the URL of the installed Sublime Text app.
    /// Checks Sublime Text 4 first, falls back to version 3.
    private var sublimeTextURL: URL? {
        NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.sublimetext.4")
        ?? NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.sublimetext.3")
    }
}
