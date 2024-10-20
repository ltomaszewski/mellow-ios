//
//  TodayTabViewModel.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 20/10/2024.
//

import SwiftUI
import Combine

class TodayTabViewModel: ObservableObject {
    @Published var progress: Float
    @Published var totalAsleep: Float
    @Published var sleepGoal: Float
    @Published var nextSleep: Int
    @Published var scoreSleep: Int
    @Published var scoreSleepMark: String
    @Published var napTimeScore: Int
    @Published var sleepDurationScore: Int
    @Published var wakeupTimeScore: Int
    @Published var threeDayConsistencyScore: Int

    init(progress: Float = 0.3,
         totalAsleep: Float = 4.5,
         sleepGoal: Float = 11,
         nextSleep: Int = 30,
         scoreSleep: Int = 86,
         scoreSleepMark: String = "Great",
         napTimeScore: Int = 86,
         sleepDurationScore: Int = 86,
         wakeupTimeScore: Int = 86,
         threeDayConsistencyScore: Int = 86) {
        self.progress = progress
        self.totalAsleep = totalAsleep
        self.sleepGoal = sleepGoal
        self.nextSleep = nextSleep
        self.scoreSleep = scoreSleep
        self.scoreSleepMark = scoreSleepMark
        self.napTimeScore = napTimeScore
        self.sleepDurationScore = sleepDurationScore
        self.wakeupTimeScore = wakeupTimeScore
        self.threeDayConsistencyScore = threeDayConsistencyScore
    }

    // Formatting functions
    func formattedHours(_ value: Float) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(value))h" : String(format: "%.1fh", value)
    }

    var formattedTotalAsleep: String {
        formattedHours(totalAsleep)
    }

    var formattedSleepGoal: String {
        formattedHours(sleepGoal)
    }

    var nextSleepText: String {
        "Nap in \(nextSleep)m"
    }
}
