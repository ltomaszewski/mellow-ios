//
//  SleepSessionEntryView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 14/08/2024.
//

import SwiftUI

struct SleepSessionEntryView: View {
    let model: SleepSessionViewModel
    
    var body: some View {
        ZStack {
            // Main Rectangle with conditional corner radius
            VStack(spacing: 0) {
                Rectangle()
                    .fill(model.sleepSession.isScheduled ? Color.black.opacity(0.2) : (model.sleepSession.type == .nap ? Color.slate300 : Color.darkIndigo))
                    .clipShape(
                        RoundedCorner(
                            radius: 12,
                            corners: model.sleepSession.isInProgress ? [.topLeft, .topRight] : .allCorners
                        )
                    )
                    .overlay(
                        Group {
                            if model.sleepSession.isScheduled {
                                RoundedCorner(
                                    radius: 12,
                                    corners: model.sleepSession.isInProgress ? [.topLeft, .topRight] : .allCorners
                                )
                                .stroke(Color.white.opacity(0.1), lineWidth: 1) // Add border color and width here
                            }
                        }
                        
                    )
                if model.sleepSession.isInProgress {
                    LinearGradient(
                        gradient: Gradient(colors: [(model.sleepSession.type == .nap ? Color.slate300 : Color.darkIndigo), Color.gunmetalBlue.opacity(0.1)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: model.height*0.3)
                }
            }
            
            if model.sleepSession.isScheduled {
                // Diagonal Lines Overlay
                DiagonalLines()
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            
            HStack {
                if model.height > 48 {
                    VStack(alignment: .leading) {
                        Text(model.text)
                            .font(.main18)
                            .foregroundStyle(.white)
                        Text(model.subText)
                            .font(.main14)
                            .foregroundColor(Color.slate100)
                        Spacer()
                    }
                } else {
                    Text(model.text)
                        .font(.main18)
                        .foregroundStyle(.white)
                    Text(model.subText)
                        .font(.main14)
                        .foregroundColor(Color.slate100)
                }
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(model.durationDescription)
                        .font(.main16)
                        .foregroundStyle(.white.opacity(0.7))
                    Spacer()
                }
            }
            .padding(.top, 16)
            .padding(.horizontal, 16)
        }
        .frame(height: model.height)
    }
}

#Preview("Night Sleep - In Progress") {
    SleepSessionEntryView(
        model: SleepSessionViewModel(
            topOffset: 0,
            height: 120,
            text: "Night Sleep",
            subText: "In Progress…",
            sleepSession: SleepSessionViewRepresentation(
                id: UUID().uuidString,
                startDate: Date(),
                endDate: nil,  // No end date means in progress
                type: .nap,
                formattedTimeRange: "22:00 - 06:00",
                isScheduled: false
            )
        )
    )
    .padding()
}
