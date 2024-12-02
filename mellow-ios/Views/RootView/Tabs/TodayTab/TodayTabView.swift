//
//  SettingsTabView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 28/08/2024.
//

import SwiftUI

struct TodayTabView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appStateStore: RAppState.Store
    @State var endSleepTriggered: Bool = false

    @StateObject var viewModel: TodayTabViewModel = .init()
    
    @State var inProgressViewHeight: CGFloat = 0.0

    var body: some View {
        ScrollView {
            VStack {
                headerView
                sleepProgressBarView
                sleepInfoView
                if appStateStore.state.sleepSessionInProgress == nil {
                    nextSessionView
                        .padding(.top, 24)
                }
                sleepScoreSection
                    .padding(.top, 24)
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .padding(.bottom, inProgressViewHeight)
        }
        .frame(maxWidth: .infinity)
        .background(Color.gunmetalBlue)
        .onAppear {
            viewModel.onAppear(appStateStore, context: modelContext)
        }
        .showInProgressBarViewIfNeeded(appStateStore.sleepSessionInProgressBinding,
                                       view: SleepSessionInProgressView(sleepSessionInProgress: appStateStore.sleepSessionInProgressBinding,
                                                                        endAction: { modelContext in appStateStore.dispatch(.endSleepSessionInProgress(modelContext))}))
        .onPreferenceChange(SleepSessionInProgressHeightPreferenceKey.self,
                            perform: { newValue in
            inProgressViewHeight = newValue.height > 0 ? newValue.height + 24 : 8
        })
    }

    // MARK: - Subviews

    private var headerView: some View {
        HStack {
            Text("Today")
                .font(.main32)
                .foregroundStyle(.white)
            Spacer()
        }
    }

    private var sleepProgressBarView: some View {
        SleepProgressBarView(progress: viewModel.progress)
            .frame(height: 90)
    }

    private var sleepInfoView: some View {
        HStack {
            sleepDetailView(
                title: "Total asleep",
                value: viewModel.formattedTotalAsleep,
                alignment: .leading
            )
            Spacer()
            sleepDetailView(
                title: "Sleep goal",
                value: viewModel.formattedSleepGoal,
                alignment: .trailing
            )
        }
    }

    private var nextSessionView: some View {
        SessionInfoView(
            infoType: .nextSession,
            scoreText: viewModel.nextSleepText,
            buttonImage: .buttonStartnow,
            buttonAction: {
                appStateStore.dispatch(.startSleepSessionInProgress(modelContext))
            })
    }

    private var sleepScoreSection: some View {
        VStack(alignment: .leading) {
            Text("Sleep score")
                .font(.main14)
                .foregroundStyle(.slateGray)
                .padding(.bottom, 8)
            
            if appStateStore.state.dayStreak > 1 {
                VStack {
                    scoreDetailView(
                        infoType: .score,
                        score: viewModel.scoreSleep,
                        rightText: viewModel.scoreSleepMark
                    )
                    scoreDetailView(
                        infoType: .napTimes,
                        rightScore: viewModel.napTimeScore
                    )
                    scoreDetailView(
                        infoType: .sleepDuration,
                        rightScore: viewModel.sleepDurationScore
                    )
                    scoreDetailView(
                        infoType: .wakeupTime,
                        rightScore: viewModel.wakeupTimeScore
                    )
                    scoreDetailView(
                        infoType: .consistency,
                        rightScore: viewModel.threeDayConsistencyScore
                    )
                }
            } else {
                SleepScoreLockedView()
            }
        }
    }

    // MARK: - Helper Views

    private func sleepDetailView(title: String, value: String, alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment) {
            Text(title)
                .font(.main14)
                .foregroundStyle(.slateGray)
            Text(value)
                .font(.main18)
                .foregroundStyle(.white)
        }
    }

    private func scoreDetailView(
        infoType: SessionInfoView.InfoType,
        score: Int? = nil,
        rightText: String? = nil,
        rightScore: Int? = nil
    ) -> some View {
        SessionInfoView(
            infoType: infoType,
            score: score,
            rightText: rightText,
            rightScore: rightScore
        )
    }
}

#Preview {
    TodayTabView()
}
