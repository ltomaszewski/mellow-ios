//
//  SleepSession+Factory.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 08/11/2024.
//

import Foundation

extension SleepSession {
    /// Factory method to create a SleepSession with type determination
    /// - Parameters:
    ///   - id: Optional ID. If provided, it will be used; otherwise, a new UUID is generated.
    ///   - startDate: The start date of the sleep session.
    ///   - endDate: The end date of the sleep session. Can be nil.
    ///   - currentDate: The current date and time. Defaults to `Date()`.
    /// - Returns: A new instance of `SleepSession` with the appropriate type.
    static func createSession(id: String? = nil, startDate: Date, endDate: Date?, currentDate: Date = Date()) -> SleepSession {
        let type: String
        if let endDate = endDate {
            // If endDate is provided, determine type based on the difference between startDate and endDate
            type = startDate.isTimeDifferenceMoreThan(hours: 3, comparedTo: endDate) ? SleepSessionType.nighttime.rawValue : SleepSessionType.nap.rawValue
        } else {
            // If endDate is nil, determine type based on the difference between currentDate and startDate
            type = startDate.isTimeDifferenceMoreThan(hours: 3, comparedTo: currentDate) ? SleepSessionType.nighttime.rawValue : SleepSessionType.nap.rawValue
        }
        
        if let id = id {
            return SleepSession(id: id, startDate: startDate, endDate: endDate, type: type)
        } else {
            return SleepSession(startDate: startDate, endDate: endDate, type: type)
        }
    }
}
