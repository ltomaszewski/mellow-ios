//
//  ProfileView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 03/09/2024.
//

import SwiftUI
import SwiftData

// TODO: This view is simple, but the depenency on AppState made it hard to mock, It has to be worked out in the future to allow easier mock strategy for faster development
struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState
    @Query(sort: \Kid.dateOfBirth) var kids: [Kid]

    @State private var currentKid: Kid?
    @State private var currentDate: Date = Date()
    @State private var hoursTracked: Int = 0
    @State private var dayStreak: Int = 0
    @State private var name: String = ""
    @State private var imageResource: ImageResource = .kidoHim
    @State private var age: String = "3 years 6 months"
    @State private var showKidsList: Bool = false
    @State private var sheetHeight: CGFloat = 300
    @State private var sheetWidth: CGFloat = 300

    var body: some View {
        VStack(spacing: 24) {
            Rectangle()
                .foregroundStyle(.white.opacity(0.1))
                .frame(height: 1)
            
            // Profile Picture and Name
            ProfileHeaderView(name: $name,
                              imageResource: $imageResource,
                              age: $age)
            .onTapGesture {
                showKidsList.toggle()
            }
            
            // Stats (Hours tracked and Day streak)
            ProfileStatsView(hoursTracked: hoursTracked,
                             dayStreak: dayStreak)
            
            // Calendar with Date and Highlighted Days
            ProfileCalendarView(currentDate: $currentDate,
                                highlightedDates: [23, 24, 25, 26, 28])
            .padding(.horizontal, 32)
            Spacer()
        }
        .background(Color.gunmetalBlue)
        .foregroundColor(.white)
        .onChange(of: currentKid, perform: { newValue in
            guard let newValue else { return }
            name = newValue.name
            age = newValue.ageFormatted
            imageResource = .kidoHim
            try? appState.databaseService.selectKid(id: newValue.id, context: modelContext)
            showKidsList = false
        })
        .onReceive(appState.databaseService.$dayStreak) { newValue in
            dayStreak = newValue
        }
        .onReceive(appState.databaseService.$hoursTracked) { newValue in
            hoursTracked = newValue
        }
        .sheet(isPresented: $showKidsList,
               content: {
            ProfileKidsListView(selectedKid: $currentKid)
            .getSize($sheetWidth, $sheetHeight)
            .presentationDetents([.height(CGFloat(sheetHeight))])
        })
        .onAppear {
            age = appState.currentKid?.ageFormatted ?? "Something is wrong"
            currentKid = appState.currentKid ?? fatalError("Kid not found") as! Kid
        }
    }
    
    func daysInMonth(date: Date) -> Int {
        let range = Calendar.current.range(of: .day, in: .month, for: date)!
        return range.count
    }
}

//#Preview {
//    ProfileView()
//        .environmentObject(AppState())
//}
