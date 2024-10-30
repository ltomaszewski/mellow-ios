//
//  TodayTabViewModel.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 20/10/2024.
//

import SwiftUI
import Combine
import SwiftData

class TodayTabViewModel: ObservableObject {
    @Published var progress: Float = 0.0
    @Published var totalAsleep: Float = 0.0
    @Published var sleepGoal: Float = 11.0
    @Published var nextSleep: Int = 0
    @Published var scoreSleep: Int = 0
    @Published var scoreSleepMark: String = ""
    @Published var napTimeScore: Int = 0
    @Published var sleepDurationScore: Int = 0
    @Published var wakeupTimeScore: Int = 0
    @Published var threeDayConsistencyScore: Int = 0

    private var cancellables = Set<AnyCancellable>()
    private let sleepManager = SleepManager()

    // MARK: - onAppear Method

    func onAppear(_ appState: AppState, context: ModelContext) {
        setupBindings(appState)
        fetchTodayData(appState, context: context)
    }

    // MARK: - Data Fetching

    private func fetchTodayData(_ appState: AppState, context: ModelContext) {
        appState.refreshSchedule()
        
        // Set the sleep goal based on the kid's age or app settings
        sleepGoal = Float(sleepManager.getIdealSleepHours(for: appState.kidAgeInMonths))
        updateProgress()
        calculateSleepScores(from: appState.sleepSessions)
    }

    private func setupBindings(_ appState: AppState) {
        // Bind total sleep time and calculate progress
        appState
            .$sleepSessions
            .sink { [weak self] sessions in
                self?.updateTotalAsleep(from: sessions)
                self?.updateProgress()
            }
            .store(in: &cancellables)

        // Bind additional scores if calculated separately
        appState
            .$sleepSessions
            .sink { [weak self] sessions in
                self?.calculateSleepScores(from: sessions)
            }
            .store(in: &cancellables)
    }

    private func updateTotalAsleep(from sessions: [SleepSessionViewRepresentation]) {
        totalAsleep = sessions
            .filter { !$0.isScheduled } // Exclude scheduled sessions
            .reduce(0) { total, session in
                let durationInHours = Float(session.durationInHours)
                return total + durationInHours
            }
    }

    private func updateProgress() {
        guard sleepGoal > 0 else { return }
        progress = min(totalAsleep / sleepGoal, 1.0)
    }

    private func calculateSleepScores(from sessions: [SleepSessionViewRepresentation]) {
        // Mock scoring calculations, can be replaced with actual logic
        scoreSleep = Int((progress * 100).rounded())
        scoreSleepMark = scoreSleep > 80 ? "Great" : scoreSleep > 50 ? "Good" : "Needs Improvement"
        
        napTimeScore = calculateNapTimeScore(from: sessions)
        sleepDurationScore = calculateDurationScore(from: sessions)
        wakeupTimeScore = calculateWakeupScore(from: sessions)
        threeDayConsistencyScore = calculateThreeDayConsistencyScore(from: sessions)
    }

    // MARK: - Scoring Calculations

    private func calculateNapTimeScore(from sessions: [SleepSessionViewRepresentation]) -> Int {
        let actualNapSessions = sessions.filter { $0.type == .nap && !$0.isScheduled }
        return actualNapSessions.isEmpty ? 70 : 90
    }

    private func calculateDurationScore(from sessions: [SleepSessionViewRepresentation]) -> Int {
        // Calculate total sleep duration excluding scheduled sessions
        let actualSleepDuration = sessions
            .filter { !$0.isScheduled }
            .reduce(Float(0)) { total, session in
                let durationInHours = Float(session.durationInHours)
                return total + durationInHours
            }
        
        return actualSleepDuration >= sleepGoal ? 100 : max(60, Int((actualSleepDuration / sleepGoal) * 100))
    }

    private func calculateWakeupScore(from sessions: [SleepSessionViewRepresentation]) -> Int {
        let actualNighttimeSessions = sessions.filter { $0.type == .nighttime && !$0.isScheduled }
        return actualNighttimeSessions.count >= 3 ? 85 : 75
    }

    private func calculateThreeDayConsistencyScore(from sessions: [SleepSessionViewRepresentation]) -> Int {
        // Filter sessions to only include actual (non-scheduled) nighttime sessions
        let actualNighttimeSessions = sessions.filter { $0.type == .nighttime && !$0.isScheduled }

        // Sort sessions by date (startDate)
        let sortedSessions = actualNighttimeSessions.sorted(by: { $0.startDate < $1.startDate })

        // Get the last three sessions, if available
        let recentSessions = Array(sortedSessions.suffix(3))
        
        // Ensure we have three sessions to evaluate consistency
        guard recentSessions.count == 3 else { return 70 } // Less than three days of data, low consistency score

        // Mock logic: check if the duration and start times are fairly consistent
        let startTimes = recentSessions.map { $0.startDate.timeIntervalSinceReferenceDate }
        let durations = recentSessions.map { ($0.endDate ?? .now).timeIntervalSince($0.startDate) }
        
        // Calculate average start time and duration
        let avgStartTime = startTimes.reduce(0, +) / Double(startTimes.count)
        let avgDuration = durations.reduce(0, +) / Double(durations.count)

        // Determine consistency: calculate average deviation for start time and duration
        let startTimeDeviation = startTimes.map { abs($0 - avgStartTime) }.reduce(0, +) / Double(startTimes.count)
        let durationDeviation = durations.map { abs($0 - avgDuration) }.reduce(0, +) / Double(durations.count)

        // Set thresholds for consistency (adjustable for accuracy)
        let isConsistent = startTimeDeviation < 3600 && durationDeviation < 1800 // Within 1 hour for start, 30 mins for duration

        // Return a higher score for consistency, lower if inconsistent
        return isConsistent ? 90 : 75
    }

    // MARK: - Formatting Helpers

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

extension SleepSessionViewRepresentation {
    var durationInHours: Double {
        (endDate ?? .now).timeIntervalSince(startDate) / 3600
    }
}
