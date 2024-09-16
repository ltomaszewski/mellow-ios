//
//  PlanPromptView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 04/09/2024.
//

import SwiftUI

struct PlanPromptView: View {
    @Binding var screenTapped: Bool
    
    let headlineTopText: String
    let headlineText: String
    let headlineBottomText: String
    let headlineBottomTextImageName: String
    let bottomText: String
    
    var body: some View {
        VStack {
            Spacer()
            VStack {
                if !headlineTopText.isEmpty {
                    Text(headlineTopText)
                        .font(.main16)
                        .foregroundColor(KidsyColors.mediumGray)
                        .padding(.bottom)
                }
                
                Text(headlineText)
                    .font(.main24)
                    .multilineTextAlignment(.center)
                
                if !headlineBottomText.isEmpty {
                    Text(headlineBottomText)
                        .font(.main16)
                        .foregroundColor(KidsyColors.mediumGray)
                        .padding(.top)
                }
                
                if !headlineBottomTextImageName.isEmpty {
                    Image(headlineBottomTextImageName)
                        .padding(.top)
                }
            }
            
            Spacer()
            if !bottomText.isEmpty {
                Text(bottomText)
                    .font(.main16)
                    .foregroundColor(KidsyColors.mediumGray)
            }
        }
        .padding(.bottom)
        .onTapGesture {
            withAnimation(.easeInOut) {
                screenTapped = true
            }
        }
    }
}

#Preview {
    PlanPromptView(screenTapped: .init(get: { false }, set: { _ in }),
                   headlineTopText: "Top headline",
                   headlineText: "Answer a few questions to start personalizing your experience.",
                   headlineBottomText: "Bootom text",
                   headlineBottomTextImageName: "notification_cta",
                   bottomText: "Tap anywhere to continue")
    .frame(maxWidth: .infinity)
    .foregroundStyle(.white)
    .background(.gunmetalBlue)
}
