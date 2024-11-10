//
//  PlanDateInputView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 22/10/2024.
//

import SwiftUI

struct PlanDateInputView: View {
    @Binding var value: Date?

    let headlineText: String
    let submitText: String

    @State private var selectedDate = Date()

    var body: some View {
        VStack {
            Spacer()
            Text(headlineText)
                .font(.main24)
                .multilineTextAlignment(.center)
                .padding()
            DatePicker("", selection: $selectedDate, displayedComponents: [.date])
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
    .background(Color.deepNight)
}
