//
//  String+Attributed.swift
//  QLPlainViewExtension
//
//  Created by neo on 3/1/26.
//

import Cocoa

extension String {
    func attributed(color: NSColor, font: NSFont) -> NSAttributedString {
        NSAttributedString(string: self, attributes: [
            .foregroundColor: color,
            .font: font
        ])
    }
}
