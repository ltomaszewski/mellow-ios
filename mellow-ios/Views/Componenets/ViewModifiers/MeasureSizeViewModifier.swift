//
//  MeasureSizeModifier.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 02/11/2024.
//

import SwiftUI

struct MeasureSizeViewModifier<PrefKey: PreferenceKey>: ViewModifier where PrefKey.Value == CGSize {
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: PrefKey.self, value: geometry.size)
                }
            )
    }
}

extension View {
    func measureSize<PrefKey: PreferenceKey>(using preferenceKey: PrefKey.Type) -> some View where PrefKey.Value == CGSize {
        self.modifier(MeasureSizeViewModifier<PrefKey>())
    }
}
