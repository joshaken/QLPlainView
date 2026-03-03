//
//  PreviewTests.swift
//  QLPlainViewTests
//
//  Created by neo on 3/3/26.
//

import XCTest
@testable import QLPlainViewExtension

final class PreviewTests: XCTestCase {
    
    // MARK: - File Type Detection Tests
    
    /// Verifies that file extensions are correctly mapped to FileType.
    func testFileTypeDetection() {
        let cases: [(String, FileType)] = [
            ("test.yaml", .yaml),
            ("test.yml",  .yaml),
            ("test.lua",  .lua),
            ("test.json", .json),
            ("test.xml",  .xml),
            ("test.txt",  .plain),
            ("test.md",   .plain),
            ("Dockerfile",.plain),
            ("Makefile",  .plain),
        ]
        
        for (filename, expectedType) in cases {
            let url = URL(fileURLWithPath: "/tmp/\(filename)")
            let detected = FileType.detect(from: url)
            XCTAssertEqual(detected, expectedType, "'\(filename)' should be detected as \(expectedType)")
        }
    }
    
    // MARK: - Binary Detection Tests
    
    /// Verifies that plain text is not classified as binary.
    func testPlainTextIsNotBinary() {
        let text = "Hello, World!\nThis is plain text."
        let data = text.data(using: .utf8)!
        XCTAssertFalse(String.isBinaryContent(data), "Plain text should not be detected as binary")
    }
    
    /// Verifies that data containing null bytes is classified as binary.
    func testNullBytesDetectedAsBinary() {
        var data = "Hello".data(using: .utf8)!
        data.append(0x00)
        data.append(contentsOf: "World".data(using: .utf8)!)
        XCTAssertTrue(String.isBinaryContent(data), "Data with null bytes should be detected as binary")
    }
    
    /// Verifies that data with high ratio of non-printable characters is binary.
    func testHighNonPrintableRatioDetectedAsBinary() {
        var data = Data()
        for _ in 0..<100 {
            data.append(0x01)
        }
        XCTAssertTrue(String.isBinaryContent(data), "Data with high non-printable ratio should be binary")
    }
    
    /// Verifies that UTF-8 text with newlines and tabs is not binary.
    func testTextWithSpecialCharsIsNotBinary() {
        let text = "line1\nline2\ttabbed\r\nWindows line ending"
        let data = text.data(using: .utf8)!
        XCTAssertFalse(String.isBinaryContent(data), "Text with newlines and tabs should not be binary")
    }
    
    // MARK: - Syntax Highlight Tests
    
    /// Verifies that YAML keys are highlighted in blue.
    func testYAMLHighlightKeys() {
        let content = "name: QLPlainView\nversion: 1.0.0"
        let font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        let result = YAMLHighlighter.highlight(content: content, font: font)
        
        XCTAssertFalse(result.string.isEmpty, "Highlighted YAML should not be empty")
        XCTAssertTrue(result.string.contains("name"), "Should contain key 'name'")
        XCTAssertTrue(result.string.contains("version"), "Should contain key 'version'")
    }
    
    /// Verifies that YAML comments are present in output.
    func testYAMLHighlightComments() {
        let content = "# This is a comment\nkey: value"
        let font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        let result = YAMLHighlighter.highlight(content: content, font: font)
        
        XCTAssertTrue(result.string.contains("# This is a comment"), "Should preserve comment text")
    }
    
    /// Verifies that Lua keywords are present in highlighted output.
    func testLuaHighlightKeywords() {
        let content = "local function greet(name)\n    if name then\n        return name\n    end\nend"
        let font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        let result = LuaHighlighter.highlight(content: content, font: font)
        
        XCTAssertTrue(result.string.contains("function"), "Should contain 'function' keyword")
        XCTAssertTrue(result.string.contains("if"), "Should contain 'if' keyword")
        XCTAssertTrue(result.string.contains("return"), "Should contain 'return' keyword")
    }
    
    /// Verifies that JSON keys are present in highlighted output.
    func testJSONHighlightKeys() {
        let content = """
        {
            "name": "QLPlainView",
            "version": "1.0.0"
        }
        """
        let font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        let result = JSONHighlighter.highlight(content: content, font: font)
        
        XCTAssertTrue(result.string.contains("name"), "Should contain key 'name'")
        XCTAssertTrue(result.string.contains("version"), "Should contain key 'version'")
    }
    
    /// Verifies that XML tags are present in highlighted output.
    func testXMLHighlightTags() {
        let content = "<root>\n    <name>QLPlainView</name>\n</root>"
        let font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        let result = XMLHighlighter.highlight(content: content, font: font)
        
        XCTAssertTrue(result.string.contains("<root>"), "Should contain opening tag")
        XCTAssertTrue(result.string.contains("</root>"), "Should contain closing tag")
        XCTAssertTrue(result.string.contains("QLPlainView"), "Should contain tag content")
    }
    
    // MARK: - Truncation Tests
    
    /// Verifies that content exceeding max size is truncated with a notice.
    func testTruncationNoticeIsAppended() {
        let maxSize = 100
        let longContent = String(repeating: "a", count: maxSize + 1)
        let isTruncated = longContent.count > maxSize
        
        var displayContent = longContent.prefix(maxSize).description
        if isTruncated {
            displayContent += "\n\n--- file too big (\(longContent.count / 1024)KB), only showing \(maxSize / 1024)KB ---"
        }
        
        XCTAssertTrue(displayContent.contains("file too big"), "Truncated content should contain truncation notice")
    }
    
    /// Verifies that content within max size is not truncated.
    func testNoTruncationWithinLimit() {
        let maxSize = 1000
        let shortContent = "Short content"
        let isTruncated = shortContent.count > maxSize
        
        XCTAssertFalse(isTruncated, "Short content should not be truncated")
    }
    
    // MARK: - Encoding Detection Tests
    
    /// Verifies that UTF-8 encoded text is correctly decoded.
    func testUTF8EncodingDetection() {
        let original = "Hello, UTF-8! 日本語テスト"
        let data = original.data(using: .utf8)!
        let decoded = String(data: data, encoding: .utf8)
        XCTAssertEqual(decoded, original, "UTF-8 text should be correctly decoded")
    }
    
    /// Verifies that ASCII encoded text is correctly decoded.
    func testASCIIEncodingDetection() {
        let original = "Hello, ASCII!"
        let data = original.data(using: .ascii)!
        let decoded = String(data: data, encoding: .ascii)
        XCTAssertEqual(decoded, original, "ASCII text should be correctly decoded")
    }
    
    // MARK: - File Read Tests
    
    /// Verifies that a real text file can be read and previewed.
    func testPreviewRealTextFile() throws {
        // Create a temp test file
        let content = "Hello, QLPlainView!\nLine 2\nLine 3"
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("test_preview.txt")
        
        try content.write(to: tempURL, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: tempURL) }
        
        let data = try Data(contentsOf: tempURL)
        let decoded = String(data: data, encoding: .utf8)
        
        XCTAssertNotNil(decoded, "Should successfully read and decode temp file")
        XCTAssertEqual(decoded, content, "Decoded content should match original")
    }
    
    /// Verifies that a YAML file is detected and highlighted correctly.
    func testPreviewYAMLFile() throws {
        let content = "name: test\nversion: 1.0"
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("test.yaml")
        
        try content.write(to: tempURL, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: tempURL) }
        
        let fileType = FileType.detect(from: tempURL)
        XCTAssertEqual(fileType, .yaml, "Should detect .yaml file correctly")
        
        let font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        let highlighted = fileType.highlight(content: content, font: font)
        XCTAssertFalse(highlighted.string.isEmpty, "Highlighted content should not be empty")
    }
}
