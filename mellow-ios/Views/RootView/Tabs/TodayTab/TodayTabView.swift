//
//  SettingsTabView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 28/08/2024.
//

import SwiftUI

struct TodayTabView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var databaseStore: DatabaseStore
    
    var progress: Float
    var totalAsleep: Float
    var sleepgoal: Float
    var nextSleep: Int
    var scoreSleep: Int
    var scoreSleepMark: String
    var napTimeScore: Int
    var sleepDurationScore: Int
    var wakeupTimeScore: Int
    var treeDayConsistencyScore: Int

    var body: some View {
        ScrollView {
            VStack {
                headerView
                SleepProgressBarView(progress: progress)
                    .frame(height: 90)
                sleepInfoView
                SessionInfoView(infoType: .nextSession,
                                scoreText: "Nap in \(nextSleep)m",
                                buttonImage: .buttonStartnow) {
                    print("Not implemented")
                }
                .padding(.top, 24)
                
                VStack(alignment: .leading) {
                    Text("Sleep score")
                        .font(.main14)
                        .foregroundStyle(.slateGray)
                        .padding(.bottom, 8)
                    VStack {
                        SessionInfoView(infoType: .score,
                                        score: scoreSleep,
                                        rightText: scoreSleepMark)
                        SessionInfoView(infoType: .napTimes,
                                        rightScore: napTimeScore)
                        SessionInfoView(infoType: .sleepDuration, rightScore: sleepDurationScore)
                        SessionInfoView(infoType: .wakeupTime, rightScore: wakeupTimeScore)
                        SessionInfoView(infoType: .consistency, rightScore: treeDayConsistencyScore)
                    }
                }
                .padding(.top, 24)
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
        }

        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.gunmetalBlue)
    }
    
    private var headerView: some View {
        HStack {
            Text("Today")
                .font(.main32)
                .foregroundStyle(.white)
            Spacer()
        }
    }
    
    private var sleepInfoView: some View {
        HStack {
            sleepDetailView(title: "Total asleep", value: totalAsleep, alignment: .leading)
            Spacer()
            sleepDetailView(title: "Sleep goal", value: sleepgoal, alignment: .trailing)
        }
    }
    
    private func sleepDetailView(title: String, value: Float, alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment) {
            Text(title)
                .font(.main14)
                .foregroundStyle(.slateGray)
            Text(value.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(value))h" : "\(value, specifier: "%.1f")h")
                .font(.main18)
                .foregroundStyle(.white)
        }
    }
}
#Preview {
    TodayTabView(progress: 0.3,
                 totalAsleep: 4.5,
                 sleepgoal: 11,
                 nextSleep: 30,
                 scoreSleep: 86,
                 scoreSleepMark: "Great",
                 napTimeScore: 86,
                 sleepDurationScore: 86,
                 wakeupTimeScore: 86,
                 treeDayConsistencyScore: 86)
}
