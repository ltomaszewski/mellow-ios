//
//  PlanQuestionView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 04/09/2024.
//

import SwiftUI

struct PlanQuestionView: View {
    @Binding var selectedOption: String

    let question: String
    let options: [String]
    let dontKnow: String
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Text(question)
                .font(.main24)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 54)
                .padding(.bottom, 32)
            
            VStack {
                // Create a BlackButton for each option
                ForEach(options, id: \.self) { option in
                    BlackButton(title: option, isInverted: true) {
                        withAnimation {
                            selectedOption = option
                        }
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }
}

#Preview {
    PlanQuestionView(selectedOption: .init(get: { "" }, set: { _ in }),
                     question: "Select your top priority",
                     options: ["Sleep", "Health"],
                     dontKnow: "Don't know")
}
