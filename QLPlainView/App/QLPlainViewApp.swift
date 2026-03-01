//
//  QLPlainViewApp.swift
//  QLPlainView
//
//  Created by neo on 2/28/26.
//

import SwiftUI

@main
struct QLPlainViewApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        registerExtension()
    }
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
    
    private func registerExtension() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/pluginkit")
        process.arguments = ["-e", "use", "-i", "com.joshaken.QLPlainView.QLPlainViewExtension"]
        try? process.run()
        process.waitUntilExit()
        
        let qlReset = Process()
        qlReset.executableURL = URL(fileURLWithPath: "/usr/bin/qlmanage")
        qlReset.arguments = ["-r"]
        try? qlReset.run()
    }
}
