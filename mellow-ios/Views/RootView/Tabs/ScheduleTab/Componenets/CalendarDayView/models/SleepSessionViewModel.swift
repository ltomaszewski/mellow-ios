//
//  SleepSessionViewModel.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 15/08/2024.
//

import Foundation
import SwiftlyBeautiful

struct SleepSessionViewModel: Hashable {
    let topOffset: CGFloat
    let height: CGFloat

    let text: String
    let subText: String
    let sleepSession: SleepSessionViewRepresentation
    
    init(topOffset: Float, height: Float, text: String, subText: String, sleepSession: SleepSessionViewRepresentation) {
        self.topOffset = CGFloat(topOffset)
        self.height = CGFloat(height)
        self.text = text
        self.subText = subText
        self.sleepSession = sleepSession
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(text)
        hasher.combine(subText)
    }
}
