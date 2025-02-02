//
//  RAppState+Debug.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 04/12/2024.
//
import Foundation

// Define your action types with CustomStringConvertible
extension OnboardingState.Action: CustomStringConvertible {
    var description: String {
        switch self {
        case .close:
            return "Close"
        case .welcomeMessageShown:
            return "Welcome message shown"
        case .setChildName(let name):
            return "Child name set to \(name)"
        case .setKidDateOfBirth(let date):
            if let date = date {
                let formatter = DateFormatter()
                formatter.dateStyle = .long
                return "Child date of birth set to \(formatter.string(from: date))"
            } else {
                return "Child date of birth set to nil"
            }
        case .setSleepTime(let time):
            if let time = time {
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                return "Sleep time set to \(formatter.string(from: time))"
            } else {
                return "Sleep time set to nil"
            }
        case .setWakeTime(let time):
            if let time = time {
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                return "Wake time set to \(formatter.string(from: time))"
            } else {
                return "Wake time set to nil"
            }
        }
    }
}

extension AppState.Action: CustomStringConvertible {
    var description: String {
        switch self {
        case .load(let context):
            return "App loaded with context \(context)"
        case .openAddKidOnboarding:
            return "User requested to add a new kid"
        case .onboarding(let action):
            return "Onboarding action: \(action)"
        case .setSelectedKid(let kid, let context):
            return "Selected kid \(kid) with context \(context)"
        case .setSelectedDate(let date):
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            return "Selected date set to \(formatter.string(from: date))"
        case .kidOperation(.create, let kid, _):
            return "Kid created: \(kid)"
        case .kidOperation(.update(let id), let kid, _):
            return "Kid updated: \(kid) with ID \(id)"
        case .kidOperation(.delete(let id), _, _):
            return "Kid deleted with ID \(id)"
        case .sleepSessionOperation(.create, let session, _):
            if let sleepSession = session {
                return "Sleep session created: \(sleepSession)"
            } else {
                return "Sleep session creation failed"
            }
        case .sleepSessionOperation(.update(let id), let session, _):
            if let sleepSession = session {
                return "Sleep session updated: \(sleepSession) with ID \(id)"
            } else {
                return "Sleep session update failed"
            }
        case .sleepSessionOperation(.delete(let id), _, _):
            return "Sleep session deleted with ID \(id)"
        case .startSleepSessionInProgress(_):
            return "Sleep session in progress started"
        case .endSleepSessionInProgress(_):
            return "Sleep session in progress ended"
        case .refreshSchedule:
            return "Schedule refreshed"
        case .updateSettings(let newSettings):
            return "App settings updated: \(newSettings)"
        case .resetSettings:
            return "App settings reset to defaults"
        case .saveCrenentials(usedID: let usedID, fullName: let fullName, email: let email):
            return "Saved credentials with User ID: \(usedID), Full Name: \(fullName), Email: \(email)"
        }
    }
}

