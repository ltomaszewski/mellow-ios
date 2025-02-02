//
//  CurrentTimeSeparatorView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 28/08/2024.
//

import SwiftUI

struct CurrentTimeSeparatorView: View {
    private let hourSlotHeight: CGFloat
    private let numberHours: CGFloat
    private let topOffset: CGFloat
    private let circleDiameter: CGFloat = 8
    
    init(hourSlotHeight: CGFloat, numberHours: CGFloat, firstDate: Date) {
        self.hourSlotHeight = hourSlotHeight
        self.numberHours = numberHours
        
        let now = Date()
        let hourDifference = Calendar.current.dateComponents([.hour, .minute], from: firstDate, to: now)
        let hourOffset = CGFloat(hourDifference.hour ?? 0)
        let minuteOffset = CGFloat(hourDifference.minute ?? 0) / 60.0
        
        self.topOffset = (hourOffset + minuteOffset) * hourSlotHeight
    }
    
    var body: some View {
        if topOffset < numberHours * hourSlotHeight {
            HStack(spacing: 0) {
                Circle()
                    .fill(Color.stateError)
                    .frame(width: circleDiameter, height: circleDiameter)
                Rectangle()
                    .fill(Color.stateError)
                    .frame(height: 2)
            }
            .padding(.top, topOffset)
        }
    }
}
