//
//  AddSleepView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 15/08/2024.
//

import SwiftUI

struct AddSleepView: View {
    let date: Date
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var appStateStore: AppState.Store
    
    let width: CGFloat
    @Binding var session: SleepSessionViewRepresentation?

    @State private var startTime: Date?
    @State private var startTimeMin: Date
    @State private var startTimeMax: Date
    
    @State private var endTime: Date?
    @State private var endTimeMin: Date
    @State private var endTimeMax: Date
    
    @State private var selectedOption: SleepSessionType
    @State private var startTimePickerVisible = true
    @State private var endTimePickerVisible = false
        
    init(date: Date, width: CGFloat, session: Binding<SleepSessionViewRepresentation?>) {
        let calendar = Calendar.current
        let now = Date()
        
        self.date = date
        self.width = width
        
        // Helper function to create date without minutes
        let dateWithoutMinutes: (Date) -> Date = { date in
            let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
            return calendar.date(from: components) ?? date
        }
        
        if let existingSession = session.wrappedValue {
            // Existing session case
            self._selectedOption = State(initialValue: existingSession.type)
            self._startTime = State(initialValue: existingSession.startDate)
            self._endTime = State(initialValue: existingSession.endDate)
            
            // Calculate time boundaries using calendar
            let startMax = calendar.date(byAdding: .hour, value: -1, to: existingSession.endDate ?? now)
            let endMin = calendar.date(byAdding: .minute, value: 15, to: existingSession.startDate)
            let endMax = calendar.date(byAdding: .hour, value: 12, to: existingSession.startDate)
            
            self._startTimeMin = .init(initialValue: .distantPast)
            self._startTimeMax = .init(initialValue: startMax ?? now)
            self._endTimeMin = .init(initialValue: endMin ?? now)
            self._endTimeMax = .init(initialValue: endMax ?? .distantFuture)
            
        } else {
            // New session case
            self._selectedOption = State(initialValue: .nap)
            
            // Initialize start time with calendar-aware date
            let initialStartDate = calendar.isDateInToday(date) ? now : date
            self._startTime = State(initialValue: initialStartDate)
            self._endTime = State(initialValue: nil)
            
            // Calculate initial boundaries
            let endMin = calendar.date(byAdding: .minute, value: 15, to: initialStartDate)
            let endMax = calendar.date(byAdding: .hour, value: 12, to: initialStartDate)
            
            self._startTimeMin = .init(initialValue: .distantPast)
            self._startTimeMax = .init(initialValue: initialStartDate)
            self._endTimeMin = .init(initialValue: endMin ?? initialStartDate)
            self._endTimeMax = .init(initialValue: endMax ?? .distantFuture)
        }
        
        self._session = session
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HeaderView(presentationMode: presentationMode,
                       saveAction: saveSession)
            .padding(.horizontal, 16)
            Text((session?.isScheduled ?? true) ? "Add Sleep" : "Edit Sleep")
                .font(.main20)
                .foregroundStyle(.white)
                .padding(.bottom, 8)
            TimePickers(startTime: $startTime,
                        startTimeMin: $startTimeMin,
                        startTimeMax: $startTimeMax,
                        endTime: $endTime,
                        endTimeMin: $endTimeMin,
                        endTimeMax: $endTimeMax,
                        startTimePickerVisible: $startTimePickerVisible,
                        endTimePickerVisible: $endTimePickerVisible,
                        width: .constant(width))
            if session != nil {
                SessionDelete(session: session,
                              presentationMode: presentationMode)
            }
        }
        .padding(.vertical, 24)
        .foregroundStyle(.white)
        .background(Color.gunmetalBlue)
        .onChange(of: endTime) { oldValue, newValue in
            guard let endTime = newValue, let startTime = startTime else { return }
            if endTime <= startTime {
                self.endTime = startTime.adding(hours: 1)!
            }
            let maxEndTime = startTime.adding(hours: 12)!
            if endTime > maxEndTime {
                self.endTime = maxEndTime
            }
            
            startTimeMin = Date.distantPast
            startTimeMax = (endTime.adding(hours: -1) ?? Date())
        }
    }
    
    private func cancel() {
        session = nil
        presentationMode.wrappedValue.dismiss()
    }
    
    private func saveSession() {
        // Ensure startTime is available
        guard let startTime else {
            // Optionally, present an alert to the user
            print("Start time is missing.")
            return
        }
        
        do {
            // Validate input parameters using the extension method
            try SleepSession.validateSessionInput(startTime: startTime, endTime: endTime)
        } catch {
            // Handle validation errors, e.g., present an alert to the user
            print("Validation error: \(error)")
            return
        }
        
        // Get the current date and time
        let currentDate = Date()
        
        // Determine if we're editing an existing session or creating a new one
        let shouldEdit = (session?.isScheduled == false) && (session?.id != nil)
        
        if shouldEdit {
            // Editing an existing unscheduled session
            guard let sessionEditId = session?.id else {
                print("Session ID is missing for editing.")
                return
            }
            
            // Create an updated session using the factory method from the extension
            let updatedSession = SleepSession.createSession(
                id: sessionEditId,
                startDate: startTime,
                endDate: endTime,
                currentDate: currentDate
            )
            
            appStateStore.dispatch(.sleepSessionOperation(.update(sessionEditId), updatedSession, modelContext))
        } else {
            // Adding a new session (either scheduled or a new unscheduled session)
            let newSession = SleepSession.createSession(
                startDate: startTime,
                endDate: endTime,
                currentDate: currentDate
            )
            
            appStateStore.dispatch(.sleepSessionOperation(.create, newSession, modelContext))
        }
        
        // Reset the session and dismiss the view
        cancel()
    }}

struct AddSleepView_Previews: PreviewProvider {
    static var previews: some View {
        AddSleepView(
            date: .now,
            width: 768,
            session: .init(get: { .mocked() }, set: { _ in }))
        
    }
}
