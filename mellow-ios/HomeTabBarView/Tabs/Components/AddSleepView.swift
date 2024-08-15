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
    
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var selectedOption = "Nap"
    
    let options = ["Nap", "Sleep"]
    
    init(date: Date) {
        self.date = date
        self.startTime = date
        self.endTime = Calendar.current.date(byAdding: .minute, value: 60, to: date) ?? .now
    }
    
    var body: some View {
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
                        let sleepSession = SleepSession(type: selectedOption == "Nap" ? .nap : .nighttime, startTime: startTime, endTime: endTime)
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
            
            
            HStack {
                Text("Start Time")
                    .font(.sfText16())
                    .foregroundStyle(.white)
                Spacer()
                DatePicker("Start Time",
                           selection: Binding(
                            get: { self.startTime },
                            set: { newValue in
                                self.startTime = newValue
                                if self.endTime <= self.startTime {
                                    self.endTime = Calendar.current.date(byAdding: .minute, value: 60, to: self.startTime) ?? self.startTime
                                }
                            }
                           ),
                           displayedComponents: .hourAndMinute)
                .labelsHidden()
                .colorInvert()
                .colorMultiply(Color("softPeriwinkle"))
            }
            
            HStack {
                Text("End Time")
                    .font(.sfText16())
                    .foregroundStyle(.white)
                Spacer()
                DatePicker("End Time",
                           selection: Binding(
                            get: { self.endTime },
                            set: { newValue in
                                self.endTime = newValue
                                if self.endTime <= self.startTime {
                                    self.startTime = Calendar.current.date(byAdding: .minute, value: -60, to: self.endTime) ?? self.endTime
                                }
                            }
                           ),
                           displayedComponents: .hourAndMinute)
                .labelsHidden()
                .colorInvert()
                .colorMultiply(Color("softPeriwinkle"))
            }
            
            Spacer()
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
