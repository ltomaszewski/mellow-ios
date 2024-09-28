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
    @Binding var minDate: Date
    @Binding var maxDate: Date
    @Binding var isDatePickerVisible: Bool
    @Binding var width: CGFloat

    @ObservedObject private var viewModel: ViewModel

    init(text: String,
         date: Binding<Date?>,
         minDate: Binding<Date>,
         maxDate: Binding<Date>,
         isDatePickerVisible: Binding<Bool>,
         width: Binding<CGFloat>) {
        self.text = text
        self._date = date
        self._minDate = minDate
        self._maxDate = maxDate
        self._isDatePickerVisible = isDatePickerVisible
        self._width = width
        self._viewModel = ObservedObject(wrappedValue: ViewModel(date: date.wrappedValue))
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(text)
                    .font(.main16)
                    .frame(alignment: .leading)
                
                Spacer()
                
                Text(viewModel.formattedDate)
                    .foregroundColor(.softPeriwinkle)
                    .font(.main16)
                    .padding(.vertical, 16)
                    .frame(maxWidth: width * 0.6)
                    .background(RoundedRectangle(cornerRadius: 6).fill(Color.charcoalBlue))
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
                    in: minDate...maxDate,
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
                    minDate: .init(get: { .distantPast }, set: { date in print("New min Date \(date)") }),
                    maxDate: .init(get: { .distantFuture }, set: { date in print("New max Date \(date)") }),
                    isDatePickerVisible: .init(get: { false }, set: { _ in }),
                    width: .init(get: { 400 }, set: { _ in }))
}
