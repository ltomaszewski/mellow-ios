//
//  SleepProgressView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 02/11/2024.
//

import SwiftUI

struct SleepSessionInProgressView: View {
    @Binding var sleepSessionInProgress: SleepSessionViewRepresentation?
    @Binding var endSleepTriggered: Bool
    
    @State private var timerText: String = ""
    @State private var timer: Timer?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Sleep in progress...")
                    .font(.main16)
                    .foregroundColor(.white)
                Text(timerText)
                    .font(.main14)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Button(action: endSleep) {
                Text("End")
                    .font(.main14)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .cornerRadius(10)
            }
            .overlay(
                Group {
                    RoundedCorner(
                        radius: 8,
                        corners: .allCorners
                    )
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                }
            )
        }
        .padding()
        .background(Color.softPeriwinkle)
        .clipShape(
            RoundedCorner(
                radius: 8,
                corners: [.topLeft, .topRight]
            )
        )
        .measureSize(using: SleepSessionInProgressHeightPreferenceKey.self)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .onChange(of: sleepSessionInProgress) { _, newValue in
            if newValue == nil {
                stopTimer()
            } else {
                startTimer()
            }
        }
    }
    
    private func startTimer() {
        updateTimerText()
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            updateTimerText()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateTimerText() {
        guard let startDate = sleepSessionInProgress?.startDate else {
            timerText = "0 minutes"
            return
        }
        
        let elapsedTime = Date().timeIntervalSince(startDate)
        let totalMinutes = Int(elapsedTime / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        if hours > 0 {
            timerText = "\(hours) hour\(hours > 1 ? "s" : "") \(minutes) minute\(minutes != 1 ? "s" : "")"
        } else {
            timerText = "\(minutes) minute\(minutes != 1 ? "s" : "")"
        }
    }
    
    private func endSleep() {
        endSleepTriggered = false
        // Additional end action logic goes here
    }
}

struct SleepProgressView_Previews: PreviewProvider {
    @State static var sleepSessionInProgress: SleepSessionViewRepresentation? = SleepSessionViewRepresentation(
        id: "1",
        startDate: Date().addingTimeInterval(-3400), // 1 hour ago
        endDate: nil,
        type: .nap,
        formattedTimeRange: "",
        isScheduled: false
    )
    @State static var endSleepTriggered = false
    
    static var previews: some View {
        SleepSessionInProgressView(
            sleepSessionInProgress: $sleepSessionInProgress,
            endSleepTriggered: $endSleepTriggered
        )
    }
}
