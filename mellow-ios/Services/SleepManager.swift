import Foundation

struct SleepSchedule {
    let wakeUpTime: Date
    let napTimes: [String: (start: Date, end: Date)]
    let bedTime: Date
}

class SleepManager {
    
    // Function to calculate the ideal total sleep time based on the kid's age
    func getIdealSleepHours(for ageInMonths: Int) -> Double {
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
    
    // Function to generate a schedule based on the age and wake-up time of the child
    func getSleepSchedule(for ageInMonths: Int, wakeUpTime: Date) -> SleepSchedule? {
        
        // If the child is old enough for scheduled sleep
        if ageInMonths > 1 {
            let totalSleepNeeded = getIdealSleepHours(for: ageInMonths)
            let naps = getNapDurations(for: ageInMonths)
            var napTimes: [String: (start: Date, end: Date)] = [:]
            
            // Calculating naps based on wake-up time
            var lastNapEnd = wakeUpTime
            for (index, (hours, minutes)) in naps.enumerated() {
                let napStartTime = Calendar.current.date(byAdding: .hour, value: 1 + index * 2, to: lastNapEnd)!
                let napEndTime = Calendar.current.date(byAdding: .hour, value: hours, to: napStartTime)!
                let finalNapEndTime = Calendar.current.date(byAdding: .minute, value: minutes, to: napEndTime)!
                
                napTimes["Nap \(index + 1)"] = (start: napStartTime, end: finalNapEndTime)
                lastNapEnd = finalNapEndTime
            }
            
            // Set bedtime, 12 hours after the wake-up time
            let bedTime = Calendar.current.date(byAdding: .hour, value: Int(24 - totalSleepNeeded), to: wakeUpTime)!
            
            return SleepSchedule(wakeUpTime: wakeUpTime, napTimes: napTimes, bedTime: bedTime)
        }
        
        // No scheduled sleep for children younger than 2 months
        return nil
    }
    
    // Function to adjust the sleep schedule based on the wake-up time
    func adjustSchedule(wakeUpTime: Date, schedule: inout SleepSchedule) {
        // Recalculate naps based on new wake-up time
        schedule = getSleepSchedule(for: 3, wakeUpTime: wakeUpTime)!
    }
    
    // Helper function to get nap durations based on age
    private func getNapDurations(for ageInMonths: Int) -> [(hours: Int, minutes: Int)] {
        if ageInMonths == 2 {
            return [(1, 15), (1, 15), (1, 15), (1, 15), (0, 30)] // 2 months
        } else if ageInMonths == 3 {
            return [(1, 15), (1, 30), (1, 30), (0, 30)]  // 3 months
        } else {
            return [(1, 0), (1, 0), (1, 0)]  // Default example for older kids
        }
    }
}
