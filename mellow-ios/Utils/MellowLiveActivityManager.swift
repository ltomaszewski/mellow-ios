//
//  MellowLiveActivityManager.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 03/01/2025.
//

import Foundation
import ActivityKit

final class MellowLiveActivityManager {
    private var currentActivity: Activity<MellowWidgetAttributes>?

    func startLiveActivity(for kidName: String, startDate: Date, expectedEndDate: Date) {
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
            currentActivity = activity
            print("Started Live Activity with ID: \(activity.id)")
        } catch {
            print("Failed to start Live Activity: \(error.localizedDescription)")
        }
    }

    func endLiveActivity() {
        guard let activity = currentActivity else {
            print("No active Live Activity to end.")
            return
        }

        Task {
            await activity.end(dismissalPolicy: .immediate)
            print("Ended Live Activity with ID: \(activity.id)")
            currentActivity = nil
        }
    }
}
