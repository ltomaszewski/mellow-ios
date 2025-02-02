//
//  AttributedString+Styled.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 01/01/2025.
//

import SwiftUI

// MARK: - AttributedString Extension
extension AttributedString {
    /// Applies a specific foreground color and font to the given text in the AttributedString.
    /// - Parameters:
    ///   - text: The substring to style.
    ///   - foregroundColor: The color to apply to the text.
    ///   - font: The font to apply to the text.
    func styled(
        for text: String,
        foregroundColor: Color,
        font: Font
    ) -> AttributedString {
        var copy = self
        if let range = copy.range(of: text) {
            copy[range].foregroundColor = foregroundColor
            copy[range].font = font
        }
        return copy
    }
}
