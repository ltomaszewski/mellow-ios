//
//  ProfileCalendarView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 03/09/2024.
//

import SwiftUI

struct ProfileCalendarView: View {
    @EnvironmentObject private var appStateStore: AppState.Store
    @Environment(\.modelContext) private var modelContext
    @Binding var currentDate: Date
    @StateObject var viewModel: ProfileCalendarViewModel
    
    init(currentDate: Binding<Date>,
         highlightedDates: [Int] = []) {
        _currentDate = currentDate
        _viewModel = StateObject(wrappedValue:
                                    ProfileCalendarViewModel(
                                        monthDate: currentDate.wrappedValue)
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: viewModel.previousMonth) {
                    Image(.arrowLeft)
                        .frame(width: 56, height: 56)
                }
                Spacer()
                Text(viewModel.monthName)
                    .font(.main16)
                Spacer()
                Button(action: viewModel.nextMonth) {
                    Image(.arrowRight)
                        .frame(width: 56, height: 56)
                }
            }
            
            Rectangle()
                .foregroundStyle(.white.opacity(0.1))
                .frame(height: 1)
            
            // Calendar Days by Column
            HStack(spacing: 8) {
                ForEach(0..<7, id: \.self) { column in
                    VStack(alignment: .center) {
                        Text(viewModel.daysOfWeek[column])
                            .font(.main14)
                        ForEach(0..<6) { row in
                            let position = column + row * 7
                            let date = position - viewModel.startDayOffset + 1
                            if position >= viewModel.startDayOffset && date <= viewModel.numberOfDays {
                                let isSelected = viewModel.isDateHighlighted(date,
                                                                             appState: appStateStore,
                                                                             context: modelContext)
                                CalendarDateView(day: date, isSelected: isSelected)
                            } else {
                                Text("")
                                    .frame(height: 32)
                                    .hidden()
                            }
                        }
                    }
                }
            }
            .padding(16)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
        .animation(.default, value: viewModel.monthDate)
        .onChange(of: viewModel.monthDate) { oldValue, newValue in
            currentDate = newValue
        }
    }
}

// Helper to format the month name from the Date
private var monthDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM"
    return formatter
}()

struct CalendarDateView: View {
    var day: Int
    var isSelected: Bool
    
    var body: some View {
        Text("\(day)")
            .font(.main14)
            .fontWeight(isSelected ? .bold : .regular)
            .frame(width: 32, height: 32)
            .background(isSelected ? Color.blue : Color.clear)
            .clipShape(Circle())
            .foregroundColor(isSelected ? .white : .gray)
    }
}

#Preview(body: {
    VStack {
        Spacer()
        ProfileCalendarView(
            currentDate: .init(get: { .now }, set: { _ in }),
            highlightedDates: [23, 24, 25, 26, 28]
        )
        .padding(16)
        Spacer()
    }
    .background(Color.gunmetalBlue)
})
