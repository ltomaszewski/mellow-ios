//
//  PlanDateInputView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 22/10/2024.
//

import SwiftUI

extension PlanDateInputView {
    enum DatePickerType {
        case date
        case time
        
        var components: DatePickerComponents {
            switch self {
            case .date:
                return [.date]
            case .time:
                return [.hourAndMinute]
            }
        }
    }
}

struct PlanDateInputView: View {
    @Binding var value: Date?

    let headlineText: String
    let submitText: String
    let datePickerType: DatePickerType
    let maximumDate: Date

    @State private var selectedDate = Date()

    init(value: Binding<Date?>,
         headlineText: String,
         submitText: String,
         datePickerType: DatePickerType = .date,
         maximumDate: Date = .distantFuture) {
        self._value = value
        self.headlineText = headlineText
        self.submitText = submitText
        self.datePickerType = datePickerType
        self.maximumDate = maximumDate
        self._selectedDate = .init(initialValue: value.wrappedValue ?? .now)
    }

    var body: some View {
        VStack {
            Spacer()
            Text(headlineText)
                .font(.main24)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .padding()
            DatePicker("",
                       selection: $selectedDate,
                       in: ...maximumDate, // Apply maximumDate or allow all dates
                       displayedComponents: datePickerType.components)
            .datePickerStyle(WheelDatePickerStyle())
            .labelsHidden()
            .colorInvert()
            .colorMultiply(.white)
            Spacer()
            SubmitButton(title: submitText) {
                withAnimation {
                    value = selectedDate
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom)
        }
    }
}

#Preview {
    PlanDateInputView(value: .constant(Date()),
                      headlineText: "Select a date",
                      submitText: "Continue",
                      datePickerType: .date,
                      maximumDate: Date())
    .onAppear {
        UIDatePicker.appearance().overrideUserInterfaceStyle = .light
    }
    .background(Color.deepNight)
}
