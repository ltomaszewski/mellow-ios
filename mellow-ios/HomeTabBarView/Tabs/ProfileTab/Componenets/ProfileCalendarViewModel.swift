//
//  ProfileCalendarViewModel.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 04/09/2024.
//

import Foundation
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

    func isDateHighlighted(_ day: Int) -> Bool {
        highlightedDates.contains(day)
    }
}
