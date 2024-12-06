//
//  OnboardingCompletedView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 04/12/2024.
//

import SwiftUI

struct PersonalizedScheduleView: View {
    var name: String = "Miki"
    var age: String = "3 yrs 5 mo"
    var naps: String = "1"
    var bedtime: String = "8:30pm"
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Text("Let’s begin your personalized schedule")
                .font(.main26)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundColor(.white)
                .padding(.horizontal, 32)
            
            Text("It’s an interactive series scientifically proven to improve your child sleep.")
                .font(.main12)
                .multilineTextAlignment(.center)
                .foregroundColor(.slateGray)
                .padding(.horizontal, 32)

            Group {
                
                SessionInfoView(infoType: .custom("Name:"), rightText: name)
                SessionInfoView(infoType: .custom("Age:"), rightText: age)
                
                HStack {
                    Text("Naps:")
                        .font(.main18)
                        .foregroundColor(.slateGray)
                    Spacer()
                    Text(naps)
                        .font(.main32)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                
                HStack {
                    Text("Bedtime:")
                        .font(.main18)
                        .foregroundColor(.slateGray)
                    Spacer()
                    Text(bedtime)
                        .font(.main32)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
            }
            
            SubmitButton(title: "Begin") {

            }
            .padding(.horizontal, 24)
            .padding(.bottom)
            
            Spacer()
        }
        .background(Color.darkBlueGray.edgesIgnoringSafeArea(.all))
        .foregroundColor(.white)
    }
}

#Preview {
    PersonalizedScheduleView()
}
