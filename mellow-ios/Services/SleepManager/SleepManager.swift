import Foundation

struct ScheduledSleepSession {
    let type: SessionType
    let startTime: Date
    let endTime: Date
    
    enum SessionType: Equatable {
        case nap(number: Int)
        case nightSleep
        
        // Manually implement Equatable conformance for associated values
        static func == (lhs: SessionType, rhs: SessionType) -> Bool {
            switch (lhs, rhs) {
            case (.nightSleep, .nightSleep):
                return true
            case (.nap(let lhsNumber), .nap(let rhsNumber)):
                return lhsNumber == rhsNumber
            default:
                return false
            }
        }
    }
}

class SleepManager {
    
    /// Returns an array of scheduled sleep sessions (naps and night sleep) based on the child's age and either wake-up time or base date.
    /// Validation: Either wakeUpTime or baseDate must be provided.
    func getSleepSchedule(for ageInMonths: Int, wakeUpTime: Date? = nil, baseDate: Date? = nil) -> [ScheduledSleepSession]? {
        
        // If no wake-up time is provided, use the ideal wake-up time calculated from the baseDate.
        let wakeUpTime = wakeUpTime ?? getIdealWakeUpTime(for: ageInMonths, baseDate: baseDate)
        
        let totalSleepNeeded = getIdealSleepHours(for: ageInMonths)
        let naps = getNapDurations(for: ageInMonths)
        let wakeWindows = getWakeWindows(for: ageInMonths)
        var sleepSessions: [ScheduledSleepSession] = []
        
        // Calculate nap times based on wake-up time
        var lastWakeTime = wakeUpTime
        for (index, (hours, minutes)) in naps.enumerated() {
            // Ensure wakeWindows array has enough elements
            guard index < wakeWindows.count else {
                print("Error: Not enough wake windows provided for the number of naps.")
                return nil
            }
            
            let wakeWindow = wakeWindows[index]
            let napStartTime = Calendar.current.date(byAdding: .minute, value: wakeWindow, to: lastWakeTime)!
            let napDurationMinutes = hours * 60 + minutes
            let napEndTime = Calendar.current.date(byAdding: .minute, value: napDurationMinutes, to: napStartTime)!
            
            sleepSessions.append(ScheduledSleepSession(type: .nap(number: index + 1), startTime: napStartTime, endTime: napEndTime))
            lastWakeTime = napEndTime
        }
        
        // Calculate bedtime
        let totalDaytimeSleep = naps.reduce(0.0) { $0 + Double($1.hours * 60 + $1.minutes) / 60.0 }
        let nightSleepDuration = totalSleepNeeded - totalDaytimeSleep
        guard nightSleepDuration > 0 else {
            print("Error: Night sleep duration calculated is non-positive.")
            return nil
        }
        let bedTime = Calendar.current.date(byAdding: .hour, value: Int(24 - nightSleepDuration), to: wakeUpTime)!
        
        sleepSessions.append(ScheduledSleepSession(type: .nightSleep, startTime: bedTime, endTime: wakeUpTime.addingTimeInterval(24 * 60 * 60)))
        
        return sleepSessions
    }
    
    // MARK: - Private Helper Methods
    
    /// Returns the ideal wake-up time based on the child's age and the provided base date. For simplicity, assume an average wake-up time of 8:00 AM relative to the base date.
    private func getIdealWakeUpTime(for ageInMonths: Int, baseDate: Date? = nil) -> Date {
        // Use the baseDate to calculate the ideal wake-up time
        let referenceDate = baseDate ?? Date()
        
        // Assuming the ideal wake-up time for most children is around 8:00 AM
        return Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: referenceDate)!
    }
    
    /// Calculates the ideal total sleep time based on the child's age.
    func getIdealSleepHours(for ageInMonths: Int) -> Double {
        switch ageInMonths {
        case 0...1:
            return 15.5
        case 2:
            return 15.5
        case 3:
            return 15
        case 4:
            return 14.5
        case 5...6:
            return 14.5
        case 7...9:
            return 14
        case 10...12:
            return 13.5
        case 13...18:
            return 13.25
        case 19...24:
            return 13
        case 25...36:
            return 12
        case 37...48:
            return 12
        default:
            return 12
        }
    }
    
    /// Provides nap durations based on the child's age.
    func getNapDurations(for ageInMonths: Int) -> [(hours: Int, minutes: Int)] {
        switch ageInMonths {
        case 1:
            return [(1, 0), (1, 0), (1, 0)]
        case 2:
            return [(1, 0), (1, 15), (1, 15), (1, 15), (0, 30)]
        case 3:
            return [(1, 15), (1, 30), (1, 30), (0, 30)]
        case 4:
            return [(1, 0), (1, 0), (1, 0), (0, 45)]
        case 5:
            // 3-4 naps totaling 2.5 - 3.5 hours
            // Let's assume 3 naps of 1 hour each
            return [(1, 0), (1, 0), (1, 0)]
        case 6:
            // 3 naps totaling 2.5 - 3.5 hours
            return [(1, 15), (1, 0), (1, 0)]  // Total 3 hours 15 minutes
        case 7:
            // 2-3 naps totaling 2.5 - 3 hours
            return [(1, 15), (1, 15), (0, 45)]  // Total 3 hours 15 minutes
        case 8:
            // 3 naps totaling 2 - 3 hours
            return [(1, 0), (1, 0), (1, 0)]  // Total 3 hours
        case 9:
            // 2 naps totaling 2 - 3 hours
            return [(1, 30), (1, 0)]  // Total 2 hours 30 minutes
        case 10...12:
            // 2 naps totaling 2 - 3 hours
            return [(1, 30), (1, 30)]  // Total 3 hours
        case 13:
            // 2 naps totaling 2 - 3 hours
            return [(1, 30), (1, 30)]
        case 14:
            // 1-2 naps
            // If 1 nap, total 2 - 3 hours
            // If 2 naps, split the time
            return [(2, 0)]  // Single nap of 2 hours
        case 15...17:
            // 1-2 naps
            return [(2, 0)]
        case 18...24:
            // 1 nap totaling 2 - 3 hours
            return [(2, 0)]
        case 25...36:
            // 1 nap totaling 1.5 - 2.5 hours
            return [(2, 0)]
        case 37...48:
            // 1 nap totaling 1 - 2 hours
            return [(1, 30)]
        default:
            return []
        }
    }
    
    /// Provides wake windows based on the child's age.
    private func getWakeWindows(for ageInMonths: Int) -> [Int] {
        switch ageInMonths {
        case 1:
            return [45, 45, 45]
        case 2:
            return [75, 75, 75, 75, 90]
        case 3:
            return [75, 90, 105, 120]
        case 4:
            return [90, 120, 150, 120]
        case 5:
            return [90, 120, 150]
        case 6:
            return [120, 150, 180]
        case 7:
            return [135, 150, 165]
        case 8:
            return [135, 150, 165]
        case 9:
            return [165, 180]
        case 10...11:
            return [180, 210]
        case 12...13:
            return [195, 225]
        case 14...17:
            // If 1 nap, wake window is 300 minutes (5 hours)
            // If 2 naps, wake windows are between 195 - 240 minutes
            return [195, 210]  // Assuming 2 naps scenario
        case 18...20:
            return [300]  // 5 hours if 1 nap
        case 21...23:
            return [315]  // 5.25 hours
        case 24...29:
            return [330]  // 5.5 hours
        case 30...48:
            return [360]  // 6 hours
        default:
            return []
        }
    }
}
