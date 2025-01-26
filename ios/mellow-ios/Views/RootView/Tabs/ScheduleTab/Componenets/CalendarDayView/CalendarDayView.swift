//
//  CalendarDayView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 14/08/2024.
//

import SwiftUI
import SwiftData

struct CalendarDayView: View {
    @EnvironmentObject var appStateStore: AppState.Store
    @ObservedObject private(set) var viewModel: CalendarDayViewModel
    @Binding private var editSleepSession: SleepSessionViewRepresentation?
    @Binding private var showEditSleepSession: Bool

    private let hourSlotHeight: CGFloat = 48
    
    // Binding to trigger scrolling action from the parent view
    @Binding private var shouldScrollToCurrentTime: Bool
    
    init(date: Binding<Date?>, editSleepSession: Binding<SleepSessionViewRepresentation?>, showEditSleepSession: Binding<Bool>, shouldScrollToCurrentTime: Binding<Bool>) {
        _viewModel = ObservedObject(wrappedValue: CalendarDayViewModel(date: date))
        _editSleepSession = editSleepSession
        _showEditSleepSession = showEditSleepSession
        _shouldScrollToCurrentTime = shouldScrollToCurrentTime
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollProxy in
                ScrollView(.vertical) {
                    ZStack {
                        hourSlots
                        sleepSessionEntries
                        currentTimeSeparator
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
        .onReceive(appStateStore.$state, perform: { state in
            viewModel.updateSleepSessionEntries(with: state.sleepSessions)
        })
        .onAppear {
            viewModel.updateSleepSessionEntries(with: appStateStore.state.sleepSessions)
        }
    }
    
    private var currentTimeSeparator: some View {
        VStack {
            if viewModel.midDayDate.isToday() {
                CurrentTimeSeparatorView(hourSlotHeight: hourSlotHeight,
                                         numberHours: CGFloat(viewModel.hours.count),
                                         firstDate: viewModel.hours.first ?? .now)
                .padding(.leading, 64)
                Spacer()
            }
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
            SleepSessionEntryView(model: model)
            .frame(height: model.height)
            .padding(.top, model.topOffset)
            .padding(.horizontal, 4)
            .padding(.leading, 72)
            .onTapGesture {
                editSleepSession = model.sleepSession
                showEditSleepSession = true
            }
        }
        .zIndex(model.sleepSession.isScheduled ? -99 : 999)
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
