//
//  SleepSessionInProgressHeightPreferenceKey.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 02/11/2024.
//

import SwiftUI

struct SleepSessionInProgressHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
