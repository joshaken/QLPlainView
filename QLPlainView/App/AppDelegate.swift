//
//  AppDelegate.swift
//  QLPlainView
//
//  Created by neo on 3/1/26.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var settingsWindow: NSWindow?
    var aboutWindow: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        NSApp.setActivationPolicy(.accessory)
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem?.button?.image = NSImage(
            systemSymbolName: "doc.text.magnifyingglass",
            accessibilityDescription: "QLPlainView"
        )
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(
            title: "Settings...",
            action: #selector(openSettings),
            keyEquivalent: ","
        ))
        menu.addItem(NSMenuItem(
            title: "About",
            action: #selector(openAbout),
            keyEquivalent: ""
        ))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(
            title: "Quit QLPlainView",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        ))
        statusItem?.menu = menu
    }
    
    @objc private func openSettings() {
        openWindow(title: "Settings", view: SettingsView(), window: &settingsWindow, size: NSRect(x: 0, y: 0, width: 360, height: 120))
    }
    
    @objc private func openAbout() {
        openWindow(title: "About", view: AboutView(), window: &aboutWindow, size: NSRect(x: 0, y: 0, width: 360, height: 200))
    }
    
    private func openWindow<V: View>(title: String, view: V, window: inout NSWindow?, size: NSRect) {
        if let existingWindow = window, existingWindow.isVisible {
            existingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        NSApp.setActivationPolicy(.regular)
        
        let newWindow = NSWindow(
            contentRect: size,
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        newWindow.title = title
        newWindow.center()
        newWindow.isReleasedWhenClosed = false
        newWindow.contentViewController = NSHostingController(rootView: view)
        
        NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: newWindow,
            queue: .main
        ) { _ in
            NSApp.setActivationPolicy(.accessory)
        }
        
        window = newWindow
        newWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
