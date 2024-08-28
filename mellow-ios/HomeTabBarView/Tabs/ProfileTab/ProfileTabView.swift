//
//  ProfileTabView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 28/08/2024.
//

import SwiftUI

struct ProfileTabView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Profile view")
                .foregroundStyle(.white)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Making VStack full screen
        .background(.gunmetalBlue)
    }
}
