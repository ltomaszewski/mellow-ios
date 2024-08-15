//
//  SleepSessionViewModel.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 15/08/2024.
//

import Foundation

struct SleepSessionViewModel: Hashable {
    let topOffset: CGFloat
    let height: CGFloat

    let text: String
    let subText: String
    let sleepSession: SleepSession
    
    init(topOffset: Float, height: Float, text: String, subText: String, sleepSession: SleepSession) {
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
