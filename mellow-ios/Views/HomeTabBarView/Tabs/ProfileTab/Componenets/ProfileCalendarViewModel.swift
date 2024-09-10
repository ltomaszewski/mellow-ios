//
//  ProfileCalendarViewModel.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 04/09/2024.
//

import Foundation
import SwiftData
import Combine

final class ProfileCalendarViewModel: ObservableObject {
    @Published var monthDate: Date
    @Published var highlightedDates: [Int]

    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter
    let daysOfWeek = ["M", "T", "W", "T", "F", "S", "S"]

    var monthName: String {
        dateFormatter.string(from: monthDate)
    }

    var numberOfDays: Int {
        guard let range = calendar.range(of: .day, in: .month, for: monthDate) else {
            return 0
        }
        return range.count
    }

    var startDayOffset: Int {
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate))!
        return (calendar.component(.weekday, from: firstDayOfMonth) - calendar.firstWeekday + 7) % 7
    }

    // Callbacks for navigation
    var onPreviousMonthTap: (() -> Void)?
    var onNextMonthTap: (() -> Void)?

    init(monthDate: Date = Date(), highlightedDates: [Int] = [], onPreviousMonthTap: (() -> Void)? = nil, onNextMonthTap: (() -> Void)? = nil) {
        self.monthDate = monthDate
        self.highlightedDates = highlightedDates
        self.onPreviousMonthTap = onPreviousMonthTap
        self.onNextMonthTap = onNextMonthTap
        
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
    }

    func previousMonth() {
        monthDate = calendar.date(byAdding: .month, value: -1, to: monthDate)!
        onPreviousMonthTap?()
    }

    func nextMonth() {
        monthDate = calendar.date(byAdding: .month, value: 1, to: monthDate)!
        onNextMonthTap?()
    }

    func isDateHighlighted(_ day: Int, databaseStore: DatabaseStore, context: ModelContext) -> Bool {
        guard let dayDate = createDayDate(for: monthDate, to: day) else {
            fatalError("Day creation for isDateHighlighted has failed")
        }
        return databaseStore.hasSession(on: dayDate, context: context)
    }
    
    private func createDayDate(for monthDate: Date, to day: Int) -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        // Extract the year and month from the given date
        var components = calendar.dateComponents([.year, .month], from: monthDate)
        
        // Set the new day value
        components.day = day
        
        // Return the new date with the updated day
        return calendar.date(from: components)
    }
}
