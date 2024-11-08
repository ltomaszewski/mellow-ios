//
//  AddSleepView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 15/08/2024.
//

import SwiftUI

struct AddSleepView: View {
    let date: Date
    @Binding var isPresented: Bool
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var appState: AppState
    
    @Binding var width: CGFloat
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
    
    private var sessionEditId: String?
    
    init(date: Date, width: Binding<CGFloat>, session: Binding<SleepSessionViewRepresentation?>, isPresented: Binding<Bool>) {
        self.date = date
        _width = width
        _isPresented = isPresented
        
        if let existingSession = session.wrappedValue {
            self.sessionEditId = existingSession.id
            self._selectedOption = State(initialValue: existingSession.type)
            self._startTime = State(initialValue: existingSession.startDate)
            self._endTime = State(initialValue: existingSession.endDate)
            
            self._startTimeMin = .init(initialValue: Date.distantPast)
            self._startTimeMax = .init(initialValue: existingSession.endDate?.adding(hours: -1) ?? Date())
            
            self._endTimeMin = .init(initialValue: existingSession.startDate.adding(hours: 1)!)
            self._endTimeMax = .init(initialValue: existingSession.startDate.adding(hours: 12)!)
            
        } else {
            self._selectedOption = State(initialValue: .nap)
            self._startTime = State(initialValue: date.isToday() ? Date().dateWithoutMinutes() : date)
            self._endTime = State(initialValue: nil)
            
            self._startTimeMin = .init(initialValue: Date.distantPast)
            self._startTimeMax = .init(initialValue: Date.distantFuture)
            
            self._endTimeMin = .init(initialValue: Date.distantPast)
            self._endTimeMax = .init(initialValue: Date.distantFuture)
        }
        _session = session
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HeaderView(isPresented: $isPresented,
                       presentationMode: presentationMode,
                       saveAction: saveSession)
            .padding(.horizontal, 16)
            Text(sessionEditId == nil ? "Add Sleep" : "Edit Sleep")
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
                        width: $width)
            if sessionEditId != nil {
                SessionDelete(session: $session,
                              isPresented: $isPresented,
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
        }
    }
    
    private func cancel() {
        session = nil
        isPresented = false
        presentationMode.wrappedValue.dismiss()
    }
    
    private func saveSession() {
        // Ensure startTime is available
        guard let startTime else { return }
        
        do {
            // Validate input parameters using the extension method
            try SleepSession.validateSessionInput(startTime: startTime, endTime: endTime)
        } catch {
            print(error)
            return
        }
        
        // Get the current date and time
        let currentDate = Date()
        
        // Determine if we're editing an existing session or creating a new one
        if let sessionEditId = sessionEditId {
            // Create a new session with the existing ID using the factory method from the extension
            let newSession = SleepSession.createSession(
                id: sessionEditId,
                startDate: startTime,
                endDate: endTime,
                currentDate: currentDate
            )
            
            // Replace the existing session in the database
            appState.databaseService.replaceSleepSession(
                sessionId: sessionEditId,
                with: newSession,
                context: modelContext
            )
        } else {
            // Create a new session without specifying an ID (a new UUID will be generated)
            let newSession = SleepSession.createSession(
                startDate: startTime,
                endDate: endTime,
                currentDate: currentDate
            )
            
            // Add the new session to the database
            appState.databaseService.addSleepSession(
                session: newSession,
                context: modelContext
            )
        }
        
        // Reset the session and dismiss the view
        session = nil
        isPresented = false
        presentationMode.wrappedValue.dismiss()
    }
}

struct AddSleepView_Previews: PreviewProvider {
    static var previews: some View {
        AddSleepView(
            date: .now,
            width: .init(get: { 768 }, set: { _ in } ),
            session: .init(get: { .mocked() }, set: { _ in }),
            isPresented: .init(get: { true }, set: { _ in } )
        )
    }
}
