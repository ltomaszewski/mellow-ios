//
//  TodayTabView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 13/08/2024.
//

import SwiftUI

struct ScheduleTabView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appStateStore: RAppState.Store
    @State var date: Date = Date.now.adjustToMidday()
    @State private var showAddSleepSession = false
    @State private var showEditSleepSession = false
    @State private var editSleepSession: SleepSessionViewRepresentation?
    @State private var sheetHeight: CGFloat = 300
    @State private var sheetWidth: CGFloat = 300
    @State private var shouldScrollToCurrentTime = false
    
    @State var inProgressViewHeight: CGFloat = 0.0
    @State var endSleepTriggered: Bool = false

    var body: some View {
        ZStack {
            VStack {
                DayPickerBarView(date: $date)
                    .frame(height: 64)
                CalendarDayViewWithPager(date: $date,
                                         editSleepSession: $editSleepSession,
                                         showEditSleepSession: $showEditSleepSession,
                                         shouldScrollToCurrentTime: $shouldScrollToCurrentTime)
                .padding(.bottom, inProgressViewHeight)
                Spacer()
            }
            .background(Color.gunmetalBlue)
            .dimmedBackground(isPresented: $showAddSleepSession)
            .dimmedBackground(isPresented: $showEditSleepSession)

            if appStateStore.state.sleepSessionInProgress == nil {
                VStack(alignment: .trailing) {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation {
                                editSleepSession = nil
                                showAddSleepSession.toggle()
                            }
                        }, label: {
                            Image("moon_blue") // Use your desired image here
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 64, height: 64) // Set the size of the image
                        })
                        .buttonStyle(PlainButtonStyle()) // Optional: Customize the button style
                    }
                    .padding([.trailing,.bottom], 16)
                }
            }
        }
        .showInProgressBarViewIfNeeded(appStateStore.sleepSessionInProgressBinding,
                                       view: SleepSessionInProgressView(sleepSessionInProgress: appStateStore.sleepSessionInProgressBinding,
                                                                        endAction: { modelContext in appStateStore.dispatch(.endSleepSessionInProgress(modelContext))}))
        .onPreferenceChange(SleepSessionInProgressHeightPreferenceKey.self,
                            perform: { newValue in
            inProgressViewHeight = newValue.height
        })
        .sheet(isPresented: $showAddSleepSession,
               content: {
            AddSleepView(date: date,
                         width: $sheetWidth,
                         session: $editSleepSession,
                         isPresented: $showAddSleepSession)
            .fixedSize(horizontal: false, vertical: true)
            .getSize($sheetWidth, $sheetHeight)
            .presentationDetents([.height(CGFloat(sheetHeight))])
        })
        .sheet(isPresented: $showEditSleepSession,
               content: {
            AddSleepView(date: date,
                         width: $sheetWidth,
                         session: $editSleepSession,
                         isPresented: $showAddSleepSession)
            .fixedSize(horizontal: false, vertical: true)
            .getSize($sheetWidth, $sheetHeight)
            .presentationDetents([.height(CGFloat(sheetHeight))])
        })
        .onChange(of: date) { _, newValue in
            appStateStore.dispatch(.setSelectedDate(newValue))
        }
    }
}

#Preview {
    ScheduleTabView().environmentObject(AppState())
}
