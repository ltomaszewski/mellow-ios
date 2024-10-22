//
//  IntroView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 04/09/2024.
//

import SwiftUI

struct IntroView: View {
    let imageResource: ImageResource
    let text: String
    let onStartForFree: () -> Void
    
    var body: some View {
        VStack {
            Spacer()

            Image(imageResource)
                .resizable()
                .frame(width: 200, height: 200)
            
            Text(text)
                .font(.main24)
                .lineSpacing(10)
                .multilineTextAlignment(.center)
                .padding(.minimum(64, 48))
            
            Spacer()

            // Start for free button
            SubmitButton(title: "Start for free",
                        action: onStartForFree)
            .padding(.bottom)
            .padding(.horizontal)
        }
        .background(.gunmetalBlue)
        .foregroundStyle(.white)
    }
}

#Preview {
    IntroView(imageResource: .kidoHer,
              text: "Science based sleep program that adapts to  your kid.") {
        print("Start her")
    }
}
