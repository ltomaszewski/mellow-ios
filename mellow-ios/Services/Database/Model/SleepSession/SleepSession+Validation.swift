//
//  SleepSession+Validation.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 08/11/2024.
//

import Foundation

extension SleepSession {
    /// Represents errors that can occur during sleep session validation.
    enum ValidationError: Error, LocalizedError {
        case startTimeMissing
        case invalidSessionFutureStartTimeNoEndDate
        case endTimeBeforeStartTime

        var errorDescription: String? {
            switch self {
            case .startTimeMissing:
                return "Start time is required to save the session."
            case .invalidSessionFutureStartTimeNoEndDate:
                return "Cannot save a session with a future start time and no end time."
            case .endTimeBeforeStartTime:
                return "End time cannot be earlier than start time."
            }
        }
    }
    
    /// Validates the input parameters for creating or updating a sleep session.
    ///
    /// - Parameters:
    ///   - startTime: The start date and time of the sleep session.
    ///   - endTime: The end date and time of the sleep session. Can be `nil`.
    /// - Throws: `ValidationError` if any validation rules are violated.
    static func validateSessionInput(startTime: Date?, endTime: Date?) throws {
        guard let startTime = startTime else {
            throw ValidationError.startTimeMissing
        }

        let currentDate = Date()

        // Validation Rule 1:
        // If endTime is nil, startTime must be <= currentDate
        if endTime == nil && startTime > currentDate {
            throw ValidationError.invalidSessionFutureStartTimeNoEndDate
        }

        // Validation Rule 2:
        // If endTime is provided, it must be after startTime
        if let endTime = endTime, endTime < startTime {
            throw ValidationError.endTimeBeforeStartTime
        }
    }
}
