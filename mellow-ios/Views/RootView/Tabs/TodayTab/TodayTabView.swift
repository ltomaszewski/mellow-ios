//
//  SettingsTabView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 28/08/2024.
//

import SwiftUI

struct TodayTabView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appState: AppState

    @StateObject var viewModel: TodayTabViewModel = .init()
    var onNextSessionButtonTapped: () -> Void

    var body: some View {
        ScrollView {
            VStack {
                headerView
                sleepProgressBarView
                sleepInfoView
                nextSessionView
                    .padding(.top, 24)
                sleepScoreSection
                    .padding(.top, 24)
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gunmetalBlue)
        .onAppear {
            viewModel.onAppear(appState, context: modelContext)
        }
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
            buttonAction: onNextSessionButtonTapped)
    }

    private var sleepScoreSection: some View {
        VStack(alignment: .leading) {
            Text("Sleep score")
                .font(.main14)
                .foregroundStyle(.slateGray)
                .padding(.bottom, 8)
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
    TodayTabView {
        print("Start next session now")
    }
}
