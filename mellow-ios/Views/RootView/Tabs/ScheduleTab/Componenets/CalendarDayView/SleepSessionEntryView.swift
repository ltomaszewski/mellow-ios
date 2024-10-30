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
                        .frame(height: geometry.size.height*0.3)
                    }
                }
                
                if model.sleepSession.isScheduled {
                    // Diagonal Lines Overlay
                    DiagonalLines()
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
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
        }
    }
}

struct RoundedCorner: InsettableShape {
    var radius: CGFloat
    var corners: UIRectCorner
    var insetAmount: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        // Adjust the rect for the inset amount
        let insetRect = rect.insetBy(dx: insetAmount, dy: insetAmount)
        
        // Create the rounded corner path
        let path = UIBezierPath(
            roundedRect: insetRect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        
        return Path(path.cgPath)
    }
    
    // Required method for InsettableShape
    func inset(by amount: CGFloat) -> some InsettableShape {
        var roundedCorner = self
        roundedCorner.insetAmount += amount
        return roundedCorner
    }
}
