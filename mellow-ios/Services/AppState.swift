//
//  AppState.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 04/09/2024.
//

import Foundation
import Combine
import SwiftData

class AppState: ObservableObject {
    @Published var isOnboardingCompleted: Bool = false
    @Published var showIntroView: Bool = true
    @Published var sleepSessions: [SleepSessionViewRepresentation] = []
    private var databaseSleepSessions: [SleepSessionViewRepresentation] = []
    
    var databaseService = DatabaseService()
    var onboardingStore = OnboardingPlanStore()
    var kidAgeInMonths : Int { currentKid?.ageInMonths ?? 0 }
    private let sleepManager: SleepManager = .init()
    private var cancellables: [AnyCancellable] = []
    private var currentKid: Kid? { databaseService.currentKid.value }
    private var currentDate: Date = .now.adjustToMidday()
    
    init() {
        setupAppState()
    }
    
    private func setupAppState() {
        isOnboardingCompleted = onboardingStore.isOnboardingCompleted()
        showIntroView = !isOnboardingCompleted
        
        databaseService
            .currentKid
            .first { $0 != nil }
            .sink { [weak self] kid in
                guard let self else { return }
                self.refreshSchedule()
            }
            .store(in: &cancellables)
        
        databaseService
            .sleepSessions
            .map { $0.map { $0.toViewRepresentation() } }
            .sink { [weak self] sleepSessions in
                guard let self else { return }
                
                self.databaseSleepSessions = sleepSessions
                
                guard let _ = self.currentKid else { return }
                self.updateCurrentDate(self.currentDate, force: true)
            }
            .store(in: &cancellables)
        
        databaseService.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
        
        onboardingStore.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }
    
    func startIntro() {
        showIntroView = true
    }
    
    func completeIntro() {
        showIntroView = false
    }
    
    func refreshSchedule() {
        self.updateCurrentDate(self.currentDate, force: true)
    }
    
    func updateCurrentDate(_ date: Date, force: Bool) {
        if !force {
            guard date != currentDate else { return }
        }
        self.currentDate = Calendar.current.startOfDay(for: date)
        guard let currentKid = currentKid else { fatalError("At this point Kid object has to be selected") }
        let ageOfCurrentKidInMonths = currentKid.ageInMonths

        // Dates to process: previous day, currentDate, next day
        let datesToProcess = [
            Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!,
            currentDate,
            Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        ]

        var allScheduledViewRepresentations: [SleepSessionViewRepresentation] = []

        for dateToProcess in datesToProcess {
            // 1. Find a night sleep session that ends on dateToProcess before midday
            let nightSleepSessions = sleepSessions.filter { session in
                return session.type == .nighttime && Calendar.current.isDate(session.endDate, equalTo: dateToProcess, toGranularity: .day) && session.endDate <= dateToProcess.adjustToMidday()
            }

            // 2. Use wakeUpTime if found; otherwise, use baseDate
            var wakeUpTime: Date?
            if let lastNightSleep = nightSleepSessions.last {
                wakeUpTime = lastNightSleep.endDate
            }

            // 3. Get the sleep schedule
            let scheduleForDate = sleepManager.getSleepSchedule(for: ageOfCurrentKidInMonths, wakeUpTime: wakeUpTime, baseDate: dateToProcess)

            // 4. Map scheduled sessions to SleepSessionViewRepresentation
            let scheduledSleepSessions = scheduleForDate?.toViewRepresentations() ?? []

            allScheduledViewRepresentations.append(contentsOf: scheduledSleepSessions)
        }

        // 5. Merge with latest data from databaseSleepSessions and filter out obsolete unscheduled sessions
        var mergedSleepSessions = self.sleepSessions.filter { session in
            // Keep sessions that:
            // - Are scheduled, or
            // - Exist in databaseSleepSessions (by matching id)
            session.isScheduled || databaseSleepSessions.contains(where: { $0.id == session.id })
        }

        // 6. Add updated database sessions, removing any outdated duplicates
        mergedSleepSessions.removeAll { session in
            databaseSleepSessions.contains(where: { $0.id == session.id })
        }
        mergedSleepSessions.append(contentsOf: databaseSleepSessions)

        // 7. Filter out scheduled sessions for dates in datesToProcess and add new scheduled sessions
        let datesSet = Set(datesToProcess.map { Calendar.current.startOfDay(for: $0) })
        let updatedSleepSessions = (
            mergedSleepSessions.filter { session in
                if session.isScheduled {
                    let sessionDate = Calendar.current.startOfDay(for: session.startDate)
                    return !datesSet.contains(sessionDate)
                } else {
                    return true
                }
            } + allScheduledViewRepresentations
        ).sorted { $0.startDate < $1.startDate }

        // Single assignment to sleepSessions
        self.sleepSessions = updatedSleepSessions
    }
    
    // MARK: - Reset Method

    func reset(context: ModelContext) {
        // Reset onboarding
        onboardingStore.resetOnboarding()
        isOnboardingCompleted = false
        showIntroView = true

        // Clear the database
        databaseService.removeAllData(context: context)

        // Clear in-memory data
        sleepSessions = []
        databaseSleepSessions = []
        
        // Reset current date
        currentDate = .now.adjustToMidday()
        
        // Reinitialize app state
        cancellables.removeAll()
        setupAppState()
    }
}
