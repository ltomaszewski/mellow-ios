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
    @State private var endTime: Date?
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
        } else {
            self._selectedOption = State(initialValue: .nap)
            self._startTime = State(initialValue: date)
            self._endTime = State(initialValue: Calendar.current.date(byAdding: .minute, value: 60, to: date) ?? date)
        }
        _session = session
    }
    
    var body: some View {
        VStack {
            header
            sleepTypePicker
            sleepTimePickers
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .background(Color.gunmetalBlue)
    }
    
    private var header: some View {
        HStack {
            Button("Cancel") {
                cancel()
            }
            .font(.sfText16())
            .foregroundStyle(Color.softPeriwinkle)
            
            Spacer()
            
            Button("Save") {
                saveSession()
            }
            .font(.sfText16())
            .foregroundStyle(Color.softPeriwinkle)
        }
    }
    
    private var sleepTypePicker: some View {
        VStack {
            Text(sessionEditId == nil ? "Add Sleep" : "Edit Sleep")
                .font(.sfText20())
                .foregroundStyle(.white)
            
            Picker("Nap or Sleep", selection: $selectedOption) {
                ForEach(SleepSessionType.allCases, id: \.self) { type in
                    Text(type.rawValue.capitalized)
                        .font(.sfText16())
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .tint(.white)
            .padding()
            .colorInvert()
            .colorMultiply(.white)
        }
    }
    
    private var sleepTimePickers: some View {
        VStack {
            SleepTimePicker(
                text: "Start Time",
                date: $startTime,
                isDatePickerVisible: $startTimePickerVisible,
                width: $width
            )
            .foregroundStyle(.white)
            
            SleepTimePicker(
                text: "End Time",
                date: $endTime,
                isDatePickerVisible: $endTimePickerVisible,
                width: $width
            )
            .foregroundStyle(.white)
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
            width: .init(get: { 200 }, set: { _ in }),
            session: .init(get: { nil }, set: { _ in })
        )
    }
}
