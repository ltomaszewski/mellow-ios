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
    @State private var showAddSleepSession = false

    var body: some View {
        ZStack {
            VStack {
                DayPickerBarView(date: $day)
                    .frame(height: 64)
                CalendarDayView(date: $day,
                                databaseStore: databaseStore)
                Spacer()
            }
            
            VStack(alignment: .trailing) {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            showAddSleepSession = true
                        }
                    }, label: {
                        Image("moon_blue") // Use your desired image here
                             .resizable()
                             .aspectRatio(contentMode: .fit)
                             .frame(width: 64, height: 64) // Set the size of the image
                    })
                    .buttonStyle(PlainButtonStyle()) // Optional: Customize the button style
                }.padding([.trailing,.bottom], 16)
            }
        }
        .sheet(isPresented: $showAddSleepSession, content: {
            AddSleepView(date: day ?? .now)
                .presentationDetents([.fraction(0.4)])
                .presentationDragIndicator(.visible)
        })
        .background(Color("gunmetalBlue"))
        
    }
}

#Preview {
    TodayTabView()
}
