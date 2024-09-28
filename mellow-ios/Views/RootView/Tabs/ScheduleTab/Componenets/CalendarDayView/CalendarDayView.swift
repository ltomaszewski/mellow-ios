//
//  CalendarDayView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 14/08/2024.
//

import SwiftUI
import SwiftData

struct CalendarDayView: View {
    @EnvironmentObject private var databaseStore: DatabaseStore
    @ObservedObject private(set) var viewModel: CalendarDayViewModel
    @Binding private var editSleepSession: SleepSession?
    @Binding private var showEditSleepSession: Bool
    
    private let hourSlotHeight: CGFloat = 48
    
    // Binding to trigger scrolling action from the parent view
    @Binding private var shouldScrollToCurrentTime: Bool
    
    init(date: Binding<Date?>, editSleepSession: Binding<SleepSession?>, showEditSleepSession: Binding<Bool>, shouldScrollToCurrentTime: Binding<Bool>, databaseStore: DatabaseStore) {
        _viewModel = ObservedObject(wrappedValue: CalendarDayViewModel(date: date, databaseStore: databaseStore))
        _editSleepSession = editSleepSession
        _showEditSleepSession = showEditSleepSession
        _shouldScrollToCurrentTime = shouldScrollToCurrentTime
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollProxy in
                ScrollView(.vertical) {
                    ZStack {
                        currentTimeSeparator
                        hourSlots
                        sleepSessionEntries
                    }
                }
                .onAppear {
                    if viewModel.date!.isToday() {
                        scrollToCurrentTimeIfNeeded(geometry: geometry, proxy: scrollProxy)
                    } else {
                        scrollToMidDay(geometry: geometry, proxy: scrollProxy)
                    }
                }
                .onChange(of: shouldScrollToCurrentTime) { _, newValue in
                    if newValue {
                        scrollToCurrentTimeIfNeeded(geometry: geometry, proxy: scrollProxy)
                        shouldScrollToCurrentTime = false // Reset the trigger after scrolling
                    }
                }
            }
        }
        .onReceive(databaseStore.$sleepSession, perform: { sessions in
            viewModel.updateSleepSessionEntries(with: sessions)
        })
        .onAppear {
            viewModel.updateSleepSessionEntries(with: databaseStore.sleepSession)
        }
    }
    
    private var currentTimeSeparator: some View {
        VStack {
            CurrentTimeSeparatorView(hourSlotHeight: hourSlotHeight,
                                     numberHours: CGFloat(viewModel.hours.count),
                                     firstDate: viewModel.hours.first ?? .now)
            .padding(.leading, 64)
            Spacer()
        }
    }
    
    private var hourSlots: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.hours, id: \.self) { date in
                DayHourSlotView(date: date)
                    .frame(height: hourSlotHeight)
                    .id(date)
            }
        }
    }
    
    private var sleepSessionEntries: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.sleepSessionsEntries, id: \.self) { model in
                sleepSessionEntry(for: model)
            }
            Spacer()
        }
    }
    
    private func sleepSessionEntry(for model: SleepSessionViewModel) -> some View {
        VStack {
            HStack {
                SleepSessionEntryView(model: model)
                    .frame(height: model.height)
            }
            .padding(.top, model.topOffset)
            .padding(.horizontal, 4)
            .padding(.leading, 72)
            .onTapGesture {
                editSleepSession = model.sleepSession
                showEditSleepSession.toggle()
            }
        }
    }
    
    private func scrollToMidDay(geometry: GeometryProxy, proxy: ScrollViewProxy) {
        let visibleHours = Int(geometry.size.height / hourSlotHeight)
        let midScreenOffset = visibleHours / 2
        proxy.scrollTo(viewModel.midDayDate.addingTimeInterval(TimeInterval(midScreenOffset * 3600)))
    }
    
    private func scrollToCurrentTimeIfNeeded(geometry: GeometryProxy, proxy: ScrollViewProxy) {
        guard Calendar.current.isDateInToday(viewModel.date!) else { return }
        let visibleHours = Int(geometry.size.height / hourSlotHeight)
        let midScreenOffset = visibleHours / 2
        proxy.scrollTo(Date().dateWithoutMinutes().addingTimeInterval(TimeInterval(midScreenOffset * 3600)))
    }
}
