//
//  TodayTabView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 13/08/2024.
//

import SwiftUI

struct TodayTabView: View {
    @EnvironmentObject var databaseStore: DatabaseStore
    @State var day: Date? = Date.now.adjustToMidday()

    var body: some View {
        VStack {
            DayPickerBarView(date: $day)
                .frame(height: 64)
            HStack {
                Button {
                    let mockedElement = SleepSession.createMockedSession(currentDate: day ?? .now)
                    mockedElement.printDescription()
                    databaseStore.add(session: mockedElement)
                } label: {
                    Text("Add Event")
                }
                Button {
                    databaseStore.remove()
                } label: {
                    Text("Remove Event")
                }
            }
            Text("\(day)")
                .foregroundStyle(.white)
            CalendarDayView(date: $day,
                            databaseStore: databaseStore)
            Spacer()
        }.background(Color("gunmetalBlue"))
    }
}

#Preview {
    TodayTabView()
}
