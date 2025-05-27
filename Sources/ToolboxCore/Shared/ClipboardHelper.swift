// ClipboardHelper.swift
// ScreenMate
//
// Created by LLM on 27 May 2025.

import AppKit

/// Utility class for clipboard operations
class ClipboardHelper {
    /// Copies the specified text to the system clipboard
    /// - Parameter text: The text to copy to the clipboard
    static func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}
