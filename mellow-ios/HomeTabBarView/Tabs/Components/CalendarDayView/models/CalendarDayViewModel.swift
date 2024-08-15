//
//  CalendarDayViewModel.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 14/08/2024.
//

import Foundation
import Combine

class CalendarDayViewModel: ObservableObject {
    
    @Published var sleepSessionsEntries: [SleepSessionViewModel] = []
    let midDayDate: Date
    var hours: [Date]
    private let hourSlotHeight: Float = 48
    private let startDate: Date
    private let endDate: Date
    private var cancellables: Set<AnyCancellable> = []
    
    init(baseDate: Date, databaseStore: DatabaseStore) {
        let midDayDate = baseDate.adjustToMidday()
        
        guard let startDate = midDayDate.adding(hours: -24) else {
            fatalError("Can not create startDate")
        }
        guard let endDate = midDayDate.adding(hours: 24) else {
            fatalError("Can not create endDate")
        }
        
        self.startDate = startDate
        self.endDate = endDate
        self.midDayDate = midDayDate
        
        let calendar = Calendar.current
        let range = -24...24
        self.hours = range.compactMap { [midDayDate] offset in
            calendar.date(byAdding: .hour, value: offset, to: midDayDate)
        }
        observeSleepSessions(in: databaseStore)
    }
    
    private func observeSleepSessions(in databaseStore: DatabaseStore) {
        databaseStore
            .$sleepSessions
            .compactMap({ [weak self] sessions -> [SleepSession] in
                guard
                    let startDate = self?.startDate,
                    let endDate = self?.endDate else {
                        fatalError("Cannot access start or end date in sleepSessions observable. This is likely an internal issue.")
                }
                return sessions.filter { $0.startTime > startDate && $0.endTime < endDate }.sorted(by: { $0.startTime < $1.startTime})
            })
            .sink { [weak self] sleepSessions in
                self?.updateSleepSessionEntries(with: sleepSessions)
            }
            .store(in: &cancellables)
    }

    private func updateSleepSessionEntries(with sleepSessions: [SleepSession]) {
        guard !sleepSessions.isEmpty else {
            sleepSessionsEntries = []
            return
        }
        let numberOfHourSlots = hours.count
        guard
            let firstDate = hours.first,
            let lastDate = hours.last else {
            fatalError("Hours data is invalid")
        }
        
        let listHeight = calculateListHeight(hourSlotHeight: hourSlotHeight, numberOfHourSlots: numberOfHourSlots)
        let listMinutesHeight = calculateListMinutesHeight(firstDate: firstDate, lastDate: lastDate, hourSlotHeight: hourSlotHeight)
        
        var result: [SleepSessionViewModel] = []
        
        for (index, session) in sleepSessions.enumerated() {
            let topOffset: Float
            let height = calculateHeight(for: session, listMinutesHeight: listMinutesHeight, listHeight: listHeight)
            
            if index == 0 {
                topOffset = calculateOffset(from: firstDate, to: session.startTime, listMinutesHeight: listMinutesHeight, listHeight: listHeight)
            } else if let lastSessionView = result.last {
                topOffset = calculateOffset(from: lastSessionView.sleepSession.endTime, to: session.startTime, listMinutesHeight: listMinutesHeight, listHeight: listHeight)
            } else {
                fatalError("There is an issue processing the sleep sessions.")
            }
            
            let sleepSessionView = SleepSessionViewModel(
                topOffset: topOffset,
                height: height,
                text: session.name,
                subText: session.formattedTimeRange,
                sleepSession: session
            )
            
            result.append(sleepSessionView)
        }
        
        sleepSessionsEntries = result
    }

    private func calculateListHeight(hourSlotHeight: Float, numberOfHourSlots: Int) -> Float {
        return Float(numberOfHourSlots) * hourSlotHeight
    }

    private func calculateListMinutesHeight(firstDate: Date, lastDate: Date, hourSlotHeight: Float) -> Float {
        return Float(firstDate.minutes(from: lastDate)) + hourSlotHeight
    }

    private func calculateHeight(for session: SleepSession, listMinutesHeight: Float, listHeight: Float) -> Float {
        let heightInMinutes = Float(session.startTime.minutes(from: session.endTime))
        let heightFactor = heightInMinutes / listMinutesHeight
        return heightFactor * listHeight
    }

    private func calculateOffset(from startDate: Date, to endDate: Date, listMinutesHeight: Float, listHeight: Float) -> Float {
        let offsetInMinutes = Float(startDate.minutes(from: endDate))
        let offsetFactor = offsetInMinutes / listMinutesHeight
        return offsetFactor * listHeight
    }
}
