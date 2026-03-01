//
//  AboutView.swift
//  QLPlainView
//
//  Created by neo on 3/1/26.
//

import SwiftUI

struct AboutView: View {
    
    private let githubURL = URL(string: "https://github.com/joshaken/QLPlainView")!
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 20) {
                // App图标
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 80, height: 80)
                
                // 右侧文字
                VStack(alignment: .leading, spacing: 6) {
                    Text("QLPlainView")
                        .font(.system(size: 20, weight: .bold))
                    
                    Text("Version 1.0.0")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Text("A macOS QuickLook Extension for previewing plain text, YAML, JSON, XML, Lua and more.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(24)
            
            Divider()
            
            // 底部按钮
            HStack(spacing: 12) {
                Spacer()
                
                Button("⭐ Star on GitHub") {
                    NSWorkspace.shared.open(githubURL)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .frame(width: 420)
    }
}
