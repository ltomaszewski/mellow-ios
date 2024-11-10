//
//  DatePickerColorViewModifier.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 10/11/2024.
//

import SwiftUI

struct DatePickerColorModifier: ViewModifier {
    let invert: Bool
    let multiplyColor: Color

    func body(content: Content) -> some View {
        content
            .if(invert) { view in
                view.colorInvert()
            }
            .colorMultiply(multiplyColor)
    }
}

// Helper extension to conditionally apply modifiers
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

extension View {
    func datePickerColor(invert: Bool = false, multiplyColor: Color = .white) -> some View {
        self.modifier(DatePickerColorModifier(invert: invert, multiplyColor: multiplyColor))
    }
}
