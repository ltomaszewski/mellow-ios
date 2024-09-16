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
    @EnvironmentObject private var databaseStore: DatabaseStore
    
    @Binding var width: CGFloat
    @Binding var session: SleepSession?
    
    @State private var startTime: Date?
    @State private var startTimeMin: Date
    @State private var startTimeMax: Date

    @State private var endTime: Date?
    @State private var endTimeMin: Date
    @State private var endTimeMax: Date
    
    @State private var selectedOption: SleepSessionType
    @State private var startTimePickerVisible = false
    @State private var endTimePickerVisible = false
    
    private var sessionEditId: UUID?
    
    init(date: Date, width: Binding<CGFloat>, session: Binding<SleepSession?>) {
        self.date = date
        _width = width
        
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
            self._startTime = State(initialValue: date)
            self._endTime = State(initialValue: Calendar.current.date(byAdding: .minute, value: 60, to: date) ?? date)
            
            self._startTimeMin = .init(initialValue: Date.distantPast)
            self._startTimeMax = .init(initialValue: Date.distantFuture)
            
            self._endTimeMin = .init(initialValue: Date.distantPast)
            self._endTimeMax = .init(initialValue: Date.distantFuture)
        }
        _session = session
    }
    
    var body: some View {
        VStack(spacing: 16) {
            header
                .padding(.horizontal, 16)
            sleepTypePicker
            sleepTimePickers
            if sessionEditId != nil {
                sleepSessionDelete
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
    
    private var header: some View {
        HStack {
            Button("Cancel") {
                cancel()
            }
            .font(.main16)
            .foregroundStyle(Color.softPeriwinkle)
            
            Spacer()
            
            Button("Save") {
                saveSession()
            }
            .font(.main16)
            .foregroundStyle(Color.softPeriwinkle)
        }
    }
    
    private var sleepTypePicker: some View {
        VStack(spacing: 0) {
            Text(sessionEditId == nil ? "Add Sleep" : "Edit Sleep")
                .font(.main20)
                .foregroundStyle(.white)
                .padding(.bottom, 8)
            
            Picker("Nap or Sleep", selection: $selectedOption) {
                ForEach(SleepSessionType.allCases, id: \.self) { type in
                    Text(type.rawValue.capitalized)
                        .font(.main16)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .tint(.white)
            .padding(.vertical)
            .colorInvert()
            .colorMultiply(.white)
            .padding(.horizontal, 16)
        }
    }
    
    private var sleepTimePickers: some View {
        VStack(spacing: 16) {
            CalendarSeparator()
            SleepTimePicker(
                text: "Start Time",
                date: $startTime,
                minDate: $startTimeMin,
                maxDate: $startTimeMax,
                isDatePickerVisible: $startTimePickerVisible,
                width: $width
            )
            .padding(.horizontal, 16)
            
            CalendarSeparator()
            
            SleepTimePicker(
                text: "End Time",
                date: $endTime,
                minDate: $endTimeMin,
                maxDate: $endTimeMax,
                isDatePickerVisible: $endTimePickerVisible,
                width: $width
            )
            .padding(.horizontal, 16)
        }
        .onChange(of: startTimePickerVisible) { oldValue, newValue in
            if endTimePickerVisible, !oldValue, newValue {
                endTimePickerVisible = false
            }
        }
        .onChange(of: endTimePickerVisible) { oldValue, newValue in
            if startTimePickerVisible, !oldValue, newValue {
                startTimePickerVisible = false
            }
        }
    }
    
    private var sleepSessionDelete: some View {
        VStack (spacing: 16) {
            CalendarSeparator()
            HStack {
                Text("Delete")
                    .font(.main16)
                    .multilineTextAlignment(.leading)
                Spacer()
                Button {
                    databaseStore.deleteSleepSession(id: session!.id, context: modelContext)
                    presentationMode.wrappedValue.dismiss()
                    session = nil
                } label: {
                    Image(.trash)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private func cancel() {
        presentationMode.wrappedValue.dismiss()
        session = nil
    }
    
    private func saveSession() {
        if let sessionEditId = sessionEditId {
            let newSession = SleepSession(id: sessionEditId, startDate: startTime!, endDate: endTime!, type: selectedOption.rawValue)

            databaseStore.replaceSleepSession(sessionId: sessionEditId,
                                              newSession: newSession,
                                              context: modelContext)
        } else {
            let newSession = SleepSession(startDate: startTime!, endDate: endTime!, type: selectedOption.rawValue)
            databaseStore.addSleepSession(session: newSession,
                                          context: modelContext)
        }
        
        presentationMode.wrappedValue.dismiss()
        session = nil
    }
}

struct AddSleepView_Previews: PreviewProvider {
    static var previews: some View {
        AddSleepView(
            date: .now,
            width: .init(get: { 768 }, set: { _ in }),
            session: .init(get: { .init(startDate: .now, endDate: .now, type: SleepSessionType.nap.rawValue) }, set: { _ in })
        )
    }
}
