//
//  SettingsViewController.swift
//  QLPlainView
//
//  Created by neo on 3/1/26.
//

import SwiftUI

struct SettingsView: View {
    
    enum SizeUnit: String, CaseIterable {
        case kb = "KB"
        case mb = "MB"
    }
    
    @State private var sizeValue: String = ""
    @State private var unit: SizeUnit = .kb
    @State private var showError = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text("Max Preview File Size:")
                
                TextField("100", text: $sizeValue)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 70)
                    .onChange(of: sizeValue) {
                        sizeValue = sizeValue.filter { $0.isNumber }
                        showError = false
                    }
                
                Picker("", selection: $unit) {
                    ForEach(SizeUnit.allCases, id: \.self) { u in
                        Text(u.rawValue).tag(u)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 80)
                .onChange(of: unit) {
                    convertValue()
                }
            }
            
            if showError {
                Text("Please enter a valid value")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            HStack {
                Spacer()
                Button("Cancel") {
                    NSApp.keyWindow?.close()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Save") {
                    save()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 360)
        .onAppear {
            loadCurrentValue()
        }
    }
    
    private func loadCurrentValue() {
        let saved = UserDefaults.standard.integer(forKey: "maxFileSizeBytes")
        let bytes = saved > 0 ? saved : 102400
        let kb = bytes / 1024
        if kb >= 1024 {
            unit = .mb
            sizeValue = String(kb / 1024)
        } else {
            unit = .kb
            sizeValue = String(kb)
        }
    }
    
    private func convertValue() {
        guard let value = Int(sizeValue) else { return }
        switch unit {
        case .kb:
            sizeValue = String(value * 1024)
        case .mb:
            sizeValue = String(max(1, value / 1024))
        }
    }
    
    private func save() {
        guard let value = Int(sizeValue), value > 0 else {
            showError = true
            return
        }
        let bytes = unit == .kb ? value * 1024 : value * 1024 * 1024
        UserDefaults.standard.set(bytes, forKey: "maxFileSizeBytes")
        NSApp.keyWindow?.close()
    }
}
