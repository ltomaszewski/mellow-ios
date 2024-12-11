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
    
    // New property to determine the type of DatePicker
    let datePickerType: DatePickerType
    
    @State private var selectedDate = Date()
    
    // Initializer with the new parameter
    init(value: Binding<Date?>,
         headlineText: String,
         submitText: String,
         datePickerType: DatePickerType = .date) {
        self._value = value
        self.headlineText = headlineText
        self.submitText = submitText
        self.datePickerType = datePickerType
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
            DatePicker("", selection: $selectedDate, displayedComponents: datePickerType.components)
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
                      headlineText: "When is your child's birthday?",
                      submitText: "Continue")
    .onAppear {
        UIDatePicker.appearance().overrideUserInterfaceStyle = .light
    }
    .background(Color.deepNight)
}
