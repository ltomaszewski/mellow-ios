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
        GeometryReader { geometry in
            ZStack {
                // Main Rectangle with conditional corner radius
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(model.sleepSession.type == .nap ? Color.slate300 : Color.darkIndigo)
                        .clipShape(
                            RoundedCorner(
                                radius: 12,
                                corners: model.sleepSession.isInProgress ? [.topLeft, .topRight] : .allCorners
                            )
                        )
                    if model.sleepSession.isInProgress {
                        LinearGradient(
                            gradient: Gradient(colors: [(model.sleepSession.type == .nap ? Color.slate300 : Color.darkIndigo), Color.gunmetalBlue.opacity(0.1)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: geometry.size.height*0.3)
                    }
                }
                HStack {
                    VStack(alignment: .leading) {
                        Text(model.text)
                            .font(.main18)
                            .foregroundStyle(.white)
                        Text(model.subText)
                            .font(.main14)
                            .foregroundColor(Color.slate100)
                        Spacer()
                    }
                    .padding(.top, 16)
                    Spacer()
                }
                .padding(.leading, 16)
            }
            .opacity(model.sleepSession.isScheduled ? 0.0 : 1)
        }
    }
}


struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        // Use UIBezierPath to create a path with specified rounded corners
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
