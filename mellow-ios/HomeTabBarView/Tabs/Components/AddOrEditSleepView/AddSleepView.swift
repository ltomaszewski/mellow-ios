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
    
    @State private var startTime: Date?
    @State private var endTime: Date?
    @State private var selectedOption = "Nap"
    @State private var startTimeIsDatePickerVisible = false
    @State private var endTimeIsDatePicekrVisible = false
    
    let options = ["Nap", "Sleep"]
    
    init(date: Date) {
        self.date = date
        self.startTime = date
        self.endTime = Calendar.current.date(byAdding: .minute, value: 60, to: date) ?? .now
    }
    
    var body: some View {
        VStack {
            VStack {
                VStack {
                    HStack {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Cancel")
                                .font(.sfText16())
                                .foregroundStyle(Color("softPeriwinkle"))
                        }
                        Spacer()
                        Button {
                            let sleepSession = SleepSession(type: selectedOption == "Nap" ? .nap : .nighttime, startTime: startTime ?? .now, endTime: endTime ?? .now)
                            databaseStore.add(session: sleepSession)
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Save")
                                .font(.sfText16())
                                .foregroundStyle(Color("softPeriwinkle"))
                        }
                    }
                    
                    HStack(alignment: .center) {
                        Text("Add Sleep")
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
                
                SleepTimePicker(text: "Start Time",
                                date: $startTime,
                                isDatePickerVisible: $startTimeIsDatePickerVisible)
                .foregroundStyle(.white)
                
                SleepTimePicker(text: "End Time",
                                date: $endTime,
                                isDatePickerVisible: $endTimeIsDatePicekrVisible)
                .foregroundStyle(.white)
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .background(Color("gunmetalBlue"))
    }
}

struct AddSleepView_Previews: PreviewProvider {
    static var previews: some View {
        AddSleepView(date: .now)
    }
}


private struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
