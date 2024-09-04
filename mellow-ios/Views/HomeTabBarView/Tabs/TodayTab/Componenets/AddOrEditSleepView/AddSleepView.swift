//
//  AddSleepView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 15/08/2024.
//

import SwiftUI

struct AddSleepView: View {
    let date: Date
    
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var databaseStore: DatabaseStore
    
    @Binding var width: CGFloat
    @Binding var session: SleepSession?
    
    @State private var startTime: Date?
    @State private var endTime: Date?
    @State private var selectedOption: SleepSessionType
    @State private var startTimePickerVisible = false
    @State private var endTimePickerVisible = false
    
    private var sessionEditId: String?
    
    init(date: Date, width: Binding<CGFloat>, session: Binding<SleepSession?>) {
        self.date = date
        _width = width
        
        if let existingSession = session.wrappedValue {
            self.sessionEditId = String(existingSession.id)
            self._selectedOption = State(initialValue: existingSession.type)
            self._startTime = State(initialValue: existingSession.startTime)
            self._endTime = State(initialValue: existingSession.endTime)
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
        let newSession = SleepSession(
            type: selectedOption,
            startTime: startTime!,
            endTime: endTime!
        )
        
        if let sessionEditId = sessionEditId {
            databaseStore.replace(id: sessionEditId, newSession: newSession)
        } else {
            databaseStore.add(session: newSession)
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
