//
//  CalendarDayView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 14/08/2024.
//

import SwiftUI

struct CalendarDayView: View {
    @ObservedObject private(set) var viewModel: CalendarDayViewModel
    @Binding private var editSleepSession: SleepSession?
    @Binding private var showEditSleepSession: Bool
    
    private let hourSlotHeight: CGFloat = 48
    
    init(date: Binding<Date?>, editSleepSession: Binding<SleepSession?>, showEditSleepSession: Binding<Bool>, databaseStore: DatabaseStore) {
        _viewModel = ObservedObject(wrappedValue: CalendarDayViewModel(date: date, databaseStore: databaseStore))
        _editSleepSession = editSleepSession
        _showEditSleepSession = showEditSleepSession
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
                .onAppear { scrollToMidDay(geometry: geometry, proxy: scrollProxy) }
            }
        }
    }
    
    private var currentTimeSeparator: some View {
        VStack {
            CurrentTimeSeparator(hourSlotHeight: hourSlotHeight,
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
            Rectangle()
                .frame(height: model.topOffset)
                .foregroundColor(.clear)
            HStack {
                SleepSessionEntryView(model: model)
                    .frame(height: model.height)
            }
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
}

struct CurrentTimeSeparator: View {
    private let hourSlotHeight: CGFloat
    private let numberHours: CGFloat
    private let topOffset: CGFloat
    private let circleDiameter: CGFloat = 8
    
    init(hourSlotHeight: CGFloat, numberHours: CGFloat, firstDate: Date) {
        self.hourSlotHeight = hourSlotHeight
        self.numberHours = numberHours
        
        let now = Date()
        let hourDifference = Calendar.current.dateComponents([.hour, .minute], from: firstDate, to: now)
        let hourOffset = CGFloat(hourDifference.hour ?? 0)
        let minuteOffset = CGFloat(hourDifference.minute ?? 0) / 60.0
        
        self.topOffset = (hourOffset + minuteOffset) * hourSlotHeight
    }
    
    var body: some View {
        if topOffset < numberHours * hourSlotHeight {
            HStack(spacing: 0) {
                Circle()
                    .fill(Color.stateError)
                    .frame(width: circleDiameter, height: circleDiameter)
                Rectangle()
                    .fill(Color.stateError)
                    .frame(height: 2)
            }
            .padding(.top, topOffset)
        }
    }
}
