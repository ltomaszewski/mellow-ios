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
    private let userDefaultsKey = "currentLiveActivityId"

    init() {
        restoreLiveActivity()
    }

    func startLiveActivity(for kidName: String, startDate: Date, expectedEndDate: Date) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not enabled.")
            return
        }

        let attributes = MellowWidgetAttributes(title: "Sleep in Progress")
        let initialContentState = MellowWidgetAttributes.ContentState(
            name: kidName,
            startDate: startDate,
            expectedEndDate: expectedEndDate
        )

        do {
            let activity = try Activity<MellowWidgetAttributes>.request(
                attributes: attributes,
                content: .init(state: initialContentState, staleDate: nil)
            )
            currentActivity = activity
            saveLiveActivityId(activity.id)
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
            await activity.end(nil, dismissalPolicy: .immediate)
            clearLiveActivityId()
            print("Ended Live Activity with ID: \(activity.id)")
            currentActivity = nil
        }
    }

    private func saveLiveActivityId(_ id: String) {
        UserDefaults.standard.set(id, forKey: userDefaultsKey)
    }

    private func loadLiveActivityId() -> String? {
        UserDefaults.standard.string(forKey: userDefaultsKey)
    }

    private func clearLiveActivityId() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }

    private func restoreLiveActivity() {
        guard let savedId = loadLiveActivityId() else { return }

        Task {
            if let restoredActivity = Activity<MellowWidgetAttributes>.activities.first(where: { $0.id == savedId }) {
                currentActivity = restoredActivity
                print("Restored Live Activity with ID: \(restoredActivity.id)")
            } else {
                print("No matching live activity found for ID: \(savedId). Clearing saved data.")
                clearLiveActivityId()
            }
        }
    }
}
