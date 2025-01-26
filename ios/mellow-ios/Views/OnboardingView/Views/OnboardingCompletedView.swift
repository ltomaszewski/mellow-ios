//
//  OnboardingCompletedView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 04/12/2024.
//

import SwiftUI

struct OnboardingCompletedView: View {
    @EnvironmentObject private var appStateStore: AppState.Store
    @Binding var beginTrigger: Bool

    private var onboardingState: OnboardingState {
        appStateStore.state.onboardingState
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Text("Let’s begin your personalized schedule")
                .font(.main24)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
            
            Text("It’s an interactive series scientifically proven to improve your child sleep.")
                .font(.main14)
                .multilineTextAlignment(.center)
                .foregroundColor(.slateGray)
                .padding(.horizontal, 16)
            
            VStack(spacing: 8) {
                onboardingDetailItemView(title: "Name", value: onboardingState.childName.isEmpty ? "N/A" : onboardingState.childName)
                onboardingDetailItemView(title: "Age", value: formattedAge(from: onboardingState.kidDateOfBirth))
                onboardingDetailItemView(title: "Naps", value: "\(onboardingState.numberOfNaps)")
                onboardingDetailItemView(title: "Bedtime", value: formattedTime(from: onboardingState.sleepTime))
            }
            .padding(.top, 24)
            
            Spacer()
            
            SubmitButton(title: "Begin") {
                beginTrigger = true
            }
        }
        .padding(24)
        .foregroundColor(.white)
    }
    
    func onboardingDetailItemView(title: String, value: String) -> some View {
        HStack(alignment: .center, spacing: 3) {
            Text(title)
                .font(.main14)
                .foregroundColor(.slateGray)
            Spacer()
            Text(value)
                .font(.main14)
                .foregroundColor(.white)
        }
        .padding(14)
        .background(Color.darkBlueGray)
        .cornerRadius(12)
    }
    
    private func formattedAge(from date: Date?) -> String {
        guard let kidDateOfBirth = date else { return "" }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: kidDateOfBirth, to: Date())
        
        if let years = components.year, years > 0 {
            if let months = components.month, months > 0 {
                return "\(years) yrs \(months) mo"
            } else {
                return "\(years) yrs"
            }
        } else if let months = components.month, months > 0 {
            return "\(months) mo"
        } else {
            return "Newborn"
        }
    }
    
    private func formattedTime(from date: Date?) -> String {
        guard let date = date else { return "N/A" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    // Mock OnboardingState for preview purposes
    let mockOnboardingState = OnboardingState(
        welcomeMessageShown: true,
        childName: "Miki",
        kidDateOfBirth: Calendar.current.date(byAdding: .year, value: -3, to: Date()),
        numberOfNaps: 1,
        sleepTime: Calendar.current.date(bySettingHour: 20, minute: 30, second: 0, of: Date()),
        wakeTime: Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()),
        completed: true
    )

    // Mock AppState with the mock OnboardingState
    let mockAppState = AppState(onboardingState: mockOnboardingState)

    // Mock AppState.Store with the mock AppState
    let mockAppStateStore = AppState.Store(state: mockAppState, databaseService: DatabaseService())

    // Return the OnboardingCompletedView with the mocked store as an environment object
    OnboardingCompletedView(beginTrigger: .init(get: { false }, set: { _ in }))
        .environmentObject(mockAppStateStore)
}
