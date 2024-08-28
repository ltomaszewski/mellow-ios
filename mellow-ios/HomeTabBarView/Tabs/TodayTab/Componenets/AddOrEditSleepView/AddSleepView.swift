//
//  AddSleepView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 15/08/2024.
//

import SwiftUI

struct AddSleepView: View {
    let date: Date
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var databaseStore: DatabaseStore
    
    @Binding var width: CGFloat
    @Binding var session: SleepSession?
    
    @State private var startTime: Date?
    @State private var endTime: Date?
    @State private var selectedOption = "Nap"
    @State private var startTimeIsDatePickerVisible = false
    @State private var endTimeIsDatePicekrVisible = false
    
    let options = ["Nap", "Sleep"]
    private var sessionEditId: String?
    
    init(date: Date, width: Binding<CGFloat>, session: Binding<SleepSession?>) {
        self.date = date
        _width = width
        if let session = session.wrappedValue {
            sessionEditId = String(session.id)
            selectedOption = (session.type == .nap) ? "Nap" : "Sleep"
            _startTime = State(wrappedValue: session.startTime)
            _endTime = State(wrappedValue: session.endTime)
        } else {
            _startTime = State(wrappedValue: date)
            _endTime = State(wrappedValue: Calendar.current.date(byAdding: .minute, value: 60, to: date) ?? .now)
        }
        _session = session
    }
    
    var body: some View {
        VStack {
            VStack {
                VStack {
                    HStack {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                            session = nil
                        } label: {
                            Text("Cancel")
                                .font(.sfText16())
                                .foregroundStyle(Color.softPeriwinkle)
                        }
                        Spacer()
                        Button {
                            let sleepSession = SleepSession(type: selectedOption == "Nap" ? .nap : .nighttime, startTime: startTime ?? .now, endTime: endTime ?? .now)
                            if let sessionEditId {
                                databaseStore.replace(id: sessionEditId, newSession: sleepSession)
                            } else {
                                databaseStore.add(session: sleepSession)
                            }
                            
                            presentationMode.wrappedValue.dismiss()
                            session = nil
                        } label: {
                            Text("Save")
                                .font(.sfText16())
                                .foregroundStyle(Color.softPeriwinkle)
                        }
                    }
                    
                    HStack(alignment: .center) {
                        Text(sessionEditId == nil ? "Add Sleep" : "Edit Sleep")
                            .font(.sfText20())
                            .foregroundStyle(.white)
                    }
                }
                
                Picker("Nap or Sleep", selection: $selectedOption) {
                    ForEach(options, id: \.self) { option in
                        Text(option)
                            .font(.sfText16())
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .tint(.white) // Set the tint color here
                .padding()
                .colorInvert()
                .colorMultiply(.white)
                
                SleepTimePicker(text: "Start Time",
                                date: $startTime,
                                isDatePickerVisible: $startTimeIsDatePickerVisible,
                                width: $width)
                .foregroundStyle(.white)
                
                SleepTimePicker(text: "End Time",
                                date: $endTime,
                                isDatePickerVisible: $endTimeIsDatePicekrVisible,
                                width: $width)
                .foregroundStyle(.white)
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .background(Color.gunmetalBlue)
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
