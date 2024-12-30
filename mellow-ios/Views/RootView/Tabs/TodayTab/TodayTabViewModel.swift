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
    @Published var nextSleepText: String = ""
    @Published var scoreSleep: Int = 0
    @Published var scoreSleepMark: String = ""
    @Published var napTimeScore: Int = 0
    @Published var sleepDurationScore: Int = 0
    @Published var wakeupTimeScore: Int = 0
    @Published var threeDayConsistencyScore: Int = 0

    private var cancellables = Set<AnyCancellable>()
    private let sleepManager = SleepManager()
    private var kidAgeInMonths: Int = 0

    // MARK: - onAppear Method

    func onAppear(_ appState: AppState.Store, context: ModelContext) {
        // Compute kidAgeInMonths
        if let dateOfBirth = appState.state.selectedKid?.dateOfBirth {
            let ageComponents = Calendar.current.dateComponents([.month], from: dateOfBirth, to: Date())
            kidAgeInMonths = ageComponents.month ?? 0
        } else {
            kidAgeInMonths = 0
        }
        
        setupBindings(appState)
        fetchTodayData(appState)

        // Calculate the next expected sleep session
        calculateNextSleep(for: appState.state)
    }
    
    // MARK: - Data Fetching

    private func fetchTodayData(_ appState: AppState.Store) {
        // Set the sleep goal based on the kid's age or app settings
        sleepGoal = Float(sleepManager.getIdealSleepHours(for: kidAgeInMonths))
        updateProgress()
        calculateSleepScores(from: appState.state)
    }

    private func setupBindings(_ appState: AppState.Store) {
        // Bind total sleep time and calculate progress
        appState
            .$state
            .map { $0.sleepSessions }
            .sink { [weak self] sessions in
                self?.updateTotalAsleep(from: sessions)
                self?.updateProgress()
            }
            .store(in: &cancellables)

        // Bind additional scores if calculated separately
        appState
            .$state
            .sink { [weak self] state in
                self?.calculateSleepScores(from: state)
            }
            .store(in: &cancellables)
    }

    private func updateTotalAsleep(from sessions: [SleepSessionViewRepresentation]) {
        let calendar = Calendar.current
        let now = Date()
        
        // Today starts at midnight:
        let startOfToday = calendar.startOfDay(for: now)
        
        // Option A: End of today can be next midnight (the beginning of tomorrow)
        guard let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday) else {
            // Fallback if we can’t compute the next day for any reason.
            totalAsleep = 0
            return
        }
        
        totalAsleep = sessions
            .filter { !$0.isScheduled || !$0.isInProgress } // Exclude scheduled and in progres sessions
            .reduce(0) { total, session in
                
                // If `endDate` is nil, we treat "now" as the end of the session
                let sessionEnd = session.endDate ?? now
                
                // Calculate intersection between session interval and today's interval
                //  i.e.  [max(startOfToday, session.startDate), min(endOfToday, sessionEnd)]
                let actualStart = max(session.startDate, startOfToday)
                let actualEnd = min(sessionEnd, endOfToday)
                
                // If the session doesn't overlap with today (end <= start), skip
                guard actualEnd > actualStart else { return total }
                
                // Convert the time interval to hours
                let duration = actualEnd.timeIntervalSince(actualStart) / 3600.0
                return total + Float(duration)
            }
    }

    private func updateProgress() {
        guard sleepGoal > 0 else { return }
        progress = min(totalAsleep / sleepGoal, 1.0)
    }

    private func calculateSleepScores(from state: AppState) {
        let sessions = state.sleepSessions
        
        // Calculate individual scores
        napTimeScore = calculateNapTimeScore(from: sessions)
        sleepDurationScore = calculateDurationScore(from: sessions)
        wakeupTimeScore = calculateWakeupScore(from: sessions)
        threeDayConsistencyScore = calculateThreeDayConsistencyScore(from: sessions)
        
        // Calculate the average score for today
        scoreSleep = (napTimeScore + sleepDurationScore + wakeupTimeScore + threeDayConsistencyScore) / 4

        // Determine the sleep mark based on the average score
        scoreSleepMark = scoreSleep >= 80 ? "Great" : scoreSleep >= 50 ? "Good" : "Needs Improvement"
    }

    // MARK: - Scoring Calculations

    private func calculateNextSleep(for state: AppState) {
        // Get the current date and time
        let currentDate = Date()

        // Retrieve the kid's age in months
        let ageInMonths = kidAgeInMonths

        // Get today's sleep schedule based on the kid's age
        guard let scheduledSessions = sleepManager.getSleepSchedule(for: ageInMonths, baseDate: currentDate) else {
            nextSleep = 0 // No schedule available
            nextSleepText = "No more sessions today"
            return
        }

        // Check if there is an ongoing sleep session
        if let ongoingSession = scheduledSessions.first(where: { currentDate.isBetween($0.startTime, and: $0.endTime) }) {
            // Determine if the session is a nap or night sleep
            let sessionTypeText = ongoingSession.type == .nightSleep ? "Night sleep now" : "Nap time now"
            nextSleep = 0 // Ongoing session
            nextSleepText = sessionTypeText
        }
        // Find the next sleep session that starts after the current time
        else if let nextSession = scheduledSessions.first(where: { $0.startTime > currentDate }) {
            // Determine if the session is a nap or night sleep
            let sessionTypeText = nextSession.type == .nightSleep ? "Night in" : "Nap in"

            // Calculate the time difference in minutes between now and the next session's start time
            let timeDifferenceInMinutes = Calendar.current.dateComponents([.minute], from: currentDate, to: nextSession.startTime).minute ?? 0

            // If the time difference is more than 90 minutes, format as hours and minutes
            if timeDifferenceInMinutes > 90 {
                let hours = timeDifferenceInMinutes / 60
                let minutes = timeDifferenceInMinutes % 60
                nextSleep = timeDifferenceInMinutes // Store in minutes for further use
                nextSleepText = "\(sessionTypeText) \(hours)h \(minutes)m"
            } else {
                nextSleep = timeDifferenceInMinutes
                nextSleepText = "\(sessionTypeText) \(nextSleep)m"
            }
        } else {
            nextSleep = 0 // No upcoming sleep session found for today
            nextSleepText = "No more sessions today"
        }
    }

    private func calculateNapTimeScore(from sessions: [SleepSessionViewRepresentation], referenceDate: Date? = nil) -> Int {
        let today = if let referenceDate {
            Calendar.current.startOfDay(for: referenceDate)
        } else {
            Calendar.current.startOfDay(for: Date())
        }
        let yesterday = if referenceDate != nil {
            today
        } else {
            Calendar.current.date(byAdding: .day, value: -1, to: today)!
        }

        // Retrieve the expected sleep schedule for the current kid's age on today's date
        guard let expectedSchedule = sleepManager.getSleepSchedule(for: kidAgeInMonths, baseDate: yesterday) else {
            return 0
        }
        
        // Filter out the expected naps only
        let expectedNaps = expectedSchedule.filter { session in
            if case .nap = session.type { return true }
            return false
        }
        
        // Filter the sessions to include only actual naps taken today (not scheduled)
        let actualNaps = sessions.filter { session in
            session.type == .nap &&
            Calendar.current.isDate(session.startDate.startOfDay(), inSameDayAs: yesterday) &&
            !session.isScheduled
        }
        
        guard expectedNaps.count > 0 else {
            return 0
        }
        
        // Calculate the nap ratio and score
        let napRatio = Float(actualNaps.count) / Float(expectedNaps.count)
        let napTimeScore = Int((napRatio * 100).rounded())
        
        return napTimeScore
    }

    private func calculateDurationScore(from sessions: [SleepSessionViewRepresentation], referenceDate: Date = Date()) -> Int {
        let today = Calendar.current.startOfDay(for: referenceDate)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: referenceDate)!
        
        let idealSleepHours = Float(sleepManager.getIdealSleepHours(for: kidAgeInMonths))

        let nightSleepDuration = sessions
            .first(where: { session in
                session.type == .nighttime &&
                Calendar.current.isDate(session.startDate, inSameDayAs: yesterday) &&
                Calendar.current.isDate(session.endDate ?? Date(), inSameDayAs: today)
            })?
            .durationInHours ?? 0.0

        let napDuration = sessions
            .filter { session in
                session.type == .nap &&
                Calendar.current.isDate(session.startDate, inSameDayAs: yesterday) &&
                !session.isScheduled
            }
            .reduce(0.0) { total, session in total + Float(session.durationInHours) }

        let totalSleepDuration = Float(nightSleepDuration) + napDuration

        let durationScore = Int((min(totalSleepDuration / idealSleepHours, 1.0) * 100).rounded())

        return durationScore
    }

    private func calculateWakeupScore(from sessions: [SleepSessionViewRepresentation], referenceDate: Date = Date()) -> Int {
        let today = Calendar.current.startOfDay(for: referenceDate)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: referenceDate)!

        // 1. Identify the relevant nighttime session
        guard let nightSleepSession = sessions.first(where: {
            $0.type == .nighttime &&
            Calendar.current.isDate($0.startDate, inSameDayAs: yesterday) &&
            Calendar.current.isDate($0.endDate ?? Date(), inSameDayAs: today)
        }) else {
            return 0
        }

        // 2. Get the actual wake-up time
        guard let actualWakeUpTime = nightSleepSession.endDate else {
            return 0
        }

        // 3. Get the *ideal* wake-up time from the schedule
        guard let idealWakeUpTime = sleepManager
            .getSleepSchedule(for: kidAgeInMonths, baseDate: yesterday)?
            .first(where: {
                if case .nightSleep = $0.type { return true }
                return false
            })?.endTime
        else {
            return 0
        }

        // 4. Calculate the difference in hours
        let timeDifferenceHours = abs(actualWakeUpTime.timeIntervalSince(idealWakeUpTime)) / 3600

        // 5. Return a more “optimistic” score based on the time difference
        switch timeDifferenceHours {
        case 0..<1:
            // Very close to ideal: top score
            return 100
        case 1..<2:
            // Slightly off, but still good
            return 80
        case 2..<3:
            // Getting further, but keep some decent score
            return 60
        case 3..<4:
            // More deviation, but don’t drop to 0
            return 40
        default:
            // Large deviation, but let's still give *some* points
            return 20
        }
    }

    private func calculateThreeDayConsistencyScore(from sessions: [SleepSessionViewRepresentation]) -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        let pastThreeDays = (1..<4).map { Calendar.current.date(byAdding: .day, value: -$0, to: today)! }
        
        var dayScores: [Int] = []

        for day in pastThreeDays {
            let sessionsForDay = sessions.filter {
                Calendar.current.isDate($0.startDate, inSameDayAs: day)
            }

            let wakeUpScore = calculateWakeupScore(from: sessions, referenceDate: day)
            let durationScore = calculateDurationScore(from: sessionsForDay, referenceDate: day)
            let napTimeScore = calculateNapTimeScore(from: sessionsForDay, referenceDate: day)

            // One approach: sum up the three scores and take their average for that day
            let dailyTotal = wakeUpScore + durationScore + napTimeScore
            let dailyAverage = dailyTotal / 3
            
            dayScores.append(dailyAverage)
        }

        // Get the overall average across the three days
        guard !dayScores.isEmpty else {
            return 0
        }
        let finalScore = dayScores.reduce(0, +) / dayScores.count
        return finalScore
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
}
extension SleepSessionViewRepresentation {
    var durationInHours: Double {
        (endDate ?? .now).timeIntervalSince(startDate) / 3600
    }
}
