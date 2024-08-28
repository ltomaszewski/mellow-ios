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
            Rectangle()
                .fill(model.sleepSession.type == .nap ? Color("slate300") : Color("darkIndigo"))
                .cornerRadius(12)
            HStack {
                VStack(alignment: .leading) {
                    Text(model.text)
                        .font(.sfText18())
                        .foregroundStyle(.white)
                    Text(model.subText)
                        .font(.sfText14())
                        .foregroundColor(Color("slate100"))
                    Spacer()
                }
                .padding(.top, 16)
                Spacer()
            }
            .padding(.leading, 16)
        }
    }
}
