import Foundation

struct ScheduledSleepSession {
    let type: SessionType
    let startTime: Date
    let endTime: Date
    
    enum SessionType {
        case nap(number: Int)
        case nightSleep
    }
}

class SleepManager {
    
    /// Returns an array of scheduled sleep sessions (naps and night sleep) based on the child's age and either wake-up time or base date.
    /// Validation: Either wakeUpTime or baseDate must be provided.
    func getSleepSchedule(for ageInMonths: Int, wakeUpTime: Date? = nil, baseDate: Date? = nil) -> [ScheduledSleepSession]? {
        guard ageInMonths > 1 else { return nil }  // No schedule for children younger than 2 months
        
        // Validation: Ensure either wakeUpTime or baseDate is provided
        guard wakeUpTime != nil || baseDate != nil else {
            print("Error: Either wakeUpTime or baseDate must be provided.")
            return nil
        }
        
        // If no wake-up time is provided, use the ideal wake-up time calculated from the baseDate.
        let wakeUpTime = wakeUpTime ?? getIdealWakeUpTime(for: ageInMonths, baseDate: baseDate)
        
        let totalSleepNeeded = getIdealSleepHours(for: ageInMonths)
        let naps = getNapDurations(for: ageInMonths)
        let wakeWindows = getWakeWindows(for: ageInMonths)  // Fetch wake windows based on age
        var sleepSessions: [ScheduledSleepSession] = []
        
        // Calculate nap times based on wake-up time
        var lastWakeTime = wakeUpTime
        for (index, (hours, minutes)) in naps.enumerated() {
            let wakeWindow = wakeWindows[index]
            let napStartTime = Calendar.current.date(byAdding: .minute, value: wakeWindow, to: lastWakeTime)!
            let napEndTime = Calendar.current.date(byAdding: .minute, value: hours * 60 + minutes, to: napStartTime)!
            
            sleepSessions.append(ScheduledSleepSession(type: .nap(number: index + 1), startTime: napStartTime, endTime: napEndTime))
            lastWakeTime = napEndTime
        }
        
        // Calculate bedtime
        let totalDaytimeSleep = naps.reduce(0.0) { $0 + Double($1.hours) + Double($1.minutes) / 60.0 }
        let nightSleepDuration = totalSleepNeeded - totalDaytimeSleep
        let bedTime = Calendar.current.date(byAdding: .hour, value: Int(24 - nightSleepDuration), to: wakeUpTime)!
        
        sleepSessions.append(ScheduledSleepSession(type: .nightSleep, startTime: bedTime, endTime: wakeUpTime.addingTimeInterval(24 * 60 * 60)))
        
        return sleepSessions
    }
    
    // MARK: - Private Helper Methods
    
    /// Returns the ideal wake-up time based on the child's age and the provided base date. For simplicity, assume an average wake-up time of 7:00 AM relative to the base date.
    private func getIdealWakeUpTime(for ageInMonths: Int, baseDate: Date? = nil) -> Date {
        // Use the baseDate to calculate the ideal wake-up time
        let referenceDate = baseDate ?? Date()
        
        // Assuming the ideal wake-up time for most children is around 7:00 AM
        return Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: referenceDate)!
    }
    
    /// Calculates the ideal total sleep time based on the child's age.
    private func getIdealSleepHours(for ageInMonths: Int) -> Double {
        switch ageInMonths {
        case 0...1:
            return 15.5
        case 2:
            return 15.5
        case 3:
            return 15
        case 4...6:
            return 14.5
        case 7...9:
            return 14
        case 10...12:
            return 13.5
        case 13...18:
            return 13
        case 19...24:
            return 12.5
        case 25...36:
            return 12
        case 37...48:
            return 11.5
        default:
            return 10.5
        }
    }
    
    /// Provides nap durations based on the child's age.
    private func getNapDurations(for ageInMonths: Int) -> [(hours: Int, minutes: Int)] {
        switch ageInMonths {
        case 1:
            return [(1, 0), (1, 0), (1, 0)]  // Approximate based on 1-month-old varying naps
        case 2:
            return [(1, 0), (1, 15), (1, 15), (1, 15), (0, 30)]  // As per provided schedule
        case 3:
            return [(1, 15), (1, 30), (1, 30), (0, 30)]  // As per provided schedule
        default:
            return [(1, 0), (1, 0), (1, 0)]
        }
    }
    
    /// Provides wake windows based on the child's age.
    private func getWakeWindows(for ageInMonths: Int) -> [Int] {
        switch ageInMonths {
        case 1:
            return [45, 45, 45]  // Approximation for a 1-month-old (varies)
        case 2:
            return [75, 75, 75, 75, 90]  // As per provided schedule
        case 3:
            return [75, 90, 105, 120]  // As per provided schedule
        default:
            return [60, 60, 60]  // Default wake window
        }
    }
}
