//
//  SleepTimePicker.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 17/08/2024.
//

import SwiftUI

struct SleepTimePicker: View {
    let text: String
    @Binding var date: Date?
    @ObservedObject private var viewModel: SleepTimePicker.ViewModel
    @Binding private var isDatePickerVisible: Bool // State to manage date picker visibility
    
    init(text: String, date: Binding<Date?>, isDatePickerVisible: Binding<Bool>) {
        self.text = text
        _date = date
        _viewModel = ObservedObject(wrappedValue: ViewModel(date: date.wrappedValue))
        _isDatePickerVisible = isDatePickerVisible
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(text)
                    .font(.sfText16())
                    .padding(.trailing, 24)
                Text(viewModel.formattedDate)
                    .foregroundColor(.white)
                    .font(.sfText16())
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("slate300")))
                    .onTapGesture {
                        isDatePickerVisible.toggle()
                    }
            }
            
            if isDatePickerVisible {
                DatePicker(
                    "",
                    selection: Binding(
                        get: { viewModel.date ?? Date() },
                        set: { newValue in
                            date = newValue
                            viewModel.date = newValue
                        }
                    ),
                    displayedComponents: [.hourAndMinute, .date]
                )
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .colorInvert()
                .colorMultiply(.white)
            }
        }
        .onChange(of: date) { oldDate, newDate in
            if oldDate != newDate {
                viewModel.date = newDate
            }
        }
    }
}

#Preview {
    SleepTimePicker(text: "Start Time",
                    date: .init(get: { nil }, set: { date in print("New Test Date \(date)") }),
                    isDatePickerVisible: .init(get: { false }, set: { _ in }))
}
