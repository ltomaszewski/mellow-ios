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
    @Binding var isDatePickerVisible: Bool
    @Binding var width: CGFloat

    @ObservedObject private var viewModel: ViewModel

    init(text: String, date: Binding<Date?>, isDatePickerVisible: Binding<Bool>, width: Binding<CGFloat>) {
        self.text = text
        self._date = date
        self._isDatePickerVisible = isDatePickerVisible
        self._width = width
        self._viewModel = ObservedObject(wrappedValue: ViewModel(date: date.wrappedValue))
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(text)
                    .font(.sfText16())
                    .frame(alignment: .leading)
                
                Spacer()
                
                Text(viewModel.formattedDate)
                    .foregroundColor(.white)
                    .font(.sfText16())
                    .padding(.vertical, 16)
                    .frame(maxWidth: width * 0.6)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.slate300))
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
        .onChange(of: date) { newDate in
            viewModel.date = newDate
        }
    }
}
#Preview {
    SleepTimePicker(text: "Start Time",
                    date: .init(get: { .now }, set: { date in print("New Test Date \(date)") }),
                    isDatePickerVisible: .init(get: { false }, set: { _ in }),
                    width: .init(get: { 400 }, set: { _ in }))
}
