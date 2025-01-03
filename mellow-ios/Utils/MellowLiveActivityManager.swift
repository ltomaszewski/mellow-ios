//
//  MellowLiveActivityManager.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 03/01/2025.
//

import Foundation
import ActivityKit

struct MellowLiveActivityManager {
    static func startLiveActivity(for kidName: String, startDate: Date, expectedEndDate: Date) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not enabled.")
            return
        }
        
        let attributes = MellowWidgetAttributes(title: "Sleep in Progress")
        let initialContentState = MellowWidgetAttributes.ContentState(name: kidName,
                                                                      startDate: startDate,
                                                                      expectedEndDate: expectedEndDate)
        
        do {
            let activity = try Activity<MellowWidgetAttributes>.request(
                attributes: attributes,
                contentState: initialContentState,
                pushType: nil
            )
            print("Started Live Activity with ID: \(activity.id)")
        } catch {
            print("Failed to start Live Activity: \(error.localizedDescription)")
        }
    }
    
    static func updateLiveActivity(for activityID: String, endDate: Date? = nil) {
        guard let activity = Activity<MellowWidgetAttributes>.activities.first(where: { $0.id == activityID }) else {
            print("Activity with ID \(activityID) not found.")
            return
        }
        
        var updatedContentState = activity.contentState
        if let endDate = endDate {
            updatedContentState.startDate = endDate // Optionally adjust state if needed
        }
        
        Task {
            await activity.update(using: updatedContentState)
            print("Updated Live Activity with ID: \(activityID)")
        }
    }
    
    static func endLiveActivity(for activityID: String) {
        guard let activity = Activity<MellowWidgetAttributes>.activities.first(where: { $0.id == activityID }) else {
            print("Activity with ID \(activityID) not found.")
            return
        }
        
        Task {
            await activity.end(dismissalPolicy: .immediate)
            print("Ended Live Activity with ID: \(activityID)")
        }
    }
}
