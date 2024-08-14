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
                    let mockedElement = SleepSession.createMockedSession()
                    mockedElement.printDescription()
                    databaseStore.add(session: mockedElement)
                } label: {
                    Text("Add Event")
                }
                Button {
                    print("Remove")
                } label: {
                    Text("Remove Event")
                }
            }
            Text("\(day)")
                .foregroundStyle(.white)
            Text("Number of sessions in the store \(databaseStore.sleepSessions.count)")
                .foregroundStyle(.white)
            Spacer()
        }.background(Color("gunmetalBlue"))
    }
}

#Preview {
    TodayTabView()
}
