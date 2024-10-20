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
    @Binding var session: SleepSession?
    
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
    
    init(date: Date, width: Binding<CGFloat>, session: Binding<SleepSession?>, isPresented: Binding<Bool>) {
        self.date = date
        _width = width
        _isPresented = isPresented
        
        if let existingSession = session.wrappedValue {
            self.sessionEditId = existingSession.id
            self._selectedOption = State(initialValue: .init(rawValue: existingSession.type)!)
            self._startTime = State(initialValue: existingSession.startDate)
            self._endTime = State(initialValue: existingSession.endDate)
            
            self._startTimeMin = .init(initialValue: Date.distantPast)
            self._startTimeMax = .init(initialValue: existingSession.endDate.adding(hours: -1)!)
            
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
        .onChange(of: startTime) { oldValue, newValue in
            guard let startTime = newValue else { return }
            if endTime == nil || endTime! <= startTime {
                endTime = startTime.adding(hours: 1)
            }
            let maxEndTime = startTime.adding(hours: 12)!
            if endTime! > maxEndTime {
                endTime = maxEndTime
            }
        }
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
        if let sessionEditId = sessionEditId {
            let newSession = SleepSession(id: sessionEditId,
                                          startDate: startTime!,
                                          endDate: endTime!,
                                          type: startTime!.isTimeDifferenceMoreThan(hours: 3, comparedTo: endTime!) ? SleepSessionType.nighttime.rawValue : SleepSessionType.nap.rawValue)
            appState.databaseService.replaceSleepSession(sessionId: sessionEditId,
                                                         with: newSession,
                                                         context: modelContext)
        } else {
            let newSession = SleepSession(startDate: startTime!,
                                          endDate: endTime!,
                                          type: startTime!.isTimeDifferenceMoreThan(hours: 3, comparedTo: endTime!) ? SleepSessionType.nighttime.rawValue : SleepSessionType.nap.rawValue)
            appState.databaseService.addSleepSession(session: newSession,
                                                     context: modelContext)
        }
        
        session = nil
    }
}

struct AddSleepView_Previews: PreviewProvider {
    static var previews: some View {
        AddSleepView(
            date: .now,
            width: .init(get: { 768 }, set: { _ in } ),
            session: .init(get: { .init(startDate: .now, endDate: .now, type: SleepSessionType.nap.rawValue) }, set: { _ in }),
            isPresented: .init(get: { true }, set: { _ in } )
        )
    }
}
