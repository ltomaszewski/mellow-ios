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
    @Binding var editSleepSession: SleepSession?
    @Binding var showEditSleepSession: Bool
    @Binding var shouldScrollToCurrentTime: Bool
    
    var body: some View {
        PageViewContent(index: $date,
                        getCurrentIndex: { $0.viewModel.midDayDate },
                        nextIndex: { $0.adjustDay(by: 1) },
                        previousIndex: { $0.adjustDay(by: -1) },
                        viewBuilder: { CalendarDayView(date: .constant($0),
                                                       editSleepSession: $editSleepSession,
                                                       showEditSleepSession: $showEditSleepSession,
                                                       shouldScrollToCurrentTime: $shouldScrollToCurrentTime,
                                                       databaseStore: databaseStore) },
                        hasNextPage: { true },
                        hasPreviousPage: { true },
                        indexHasChanged: { date = $0 })
    }
}
