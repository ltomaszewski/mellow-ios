//
//  SleepSessionViewModel.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 15/08/2024.
//

import Foundation
import SwiftlyBeautiful

@Printable
struct SleepSessionViewModel: Hashable {
    let topOffset: CGFloat
    let height: CGFloat

    let text: String
    let subText: String
    let sleepSession: SleepSessionViewRepresentation
    
    // MARK: - Compound Property: durationDescription
    var durationDescription: String {
        // 1. Determine the end date. If nil, use the current Date()
        let end = sleepSession.endDate ?? Date()
        
        // 2. Calculate time interval in seconds
        let interval = end.timeIntervalSince(sleepSession.startDate)
        
        // In case end < start for some reason, ensure we don't get negatives.
        let totalSeconds = max(interval, 0)
        
        // 3. Convert interval to minutes
        let totalMinutes = Int(totalSeconds / 60)
        
        // 4. If under 60 minutes, display in minutes
        if totalMinutes < 60 {
            return "\(totalMinutes)m"
        } else {
            // 5. For 60+ minutes, show only truncated full hours
            let hours = totalMinutes / 60
            return "\(hours)h"
        }
    }

    init(
        topOffset: Float,
        height: Float,
        text: String,
        subText: String,
        sleepSession: SleepSessionViewRepresentation
    ) {
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
