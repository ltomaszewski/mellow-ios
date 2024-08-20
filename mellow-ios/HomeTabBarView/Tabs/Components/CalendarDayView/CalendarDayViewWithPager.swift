//
//  CalendarDayViewWithPager.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 20/08/2024.
//

import SwiftUI

struct CalendarDayViewWithPager: View {
    var databaseStore: DatabaseStore
    @Binding var date: Date
    
    // TODO: If date has changed via tab on date bar the pageViewContent has to scroll to that view
    var body: some View {
        PageViewContent<CalendarDayView, Date>(startIndex: date,
                                               getCurrentIndex: { $0.viewModel.midDayDate },
                                               nextIndex: { $0.adjustDay(by: 1) },
                                               previousIndex: { $0.adjustDay(by: -1) },
                                               viewBuilder: { CalendarDayView(date: .constant($0), databaseStore: databaseStore) },
                                               hasNextPage: { true },
                                               hasPreviousPage: { true },
                                               indexHasChanged: { date = $0 })
    }
}
