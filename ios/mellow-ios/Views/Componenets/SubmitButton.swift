//
//  BlackButton.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 04/09/2024.
//

import SwiftUI

struct SubmitButton: View {
    let title: String
    var isInverted: Bool = false // Default is false, so it uses the original style by default
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.main18)
                .foregroundColor(isInverted ? .white : .white) // Choose color based on isInverted
                .padding()
                .frame(maxWidth: .infinity) // Ensures the button takes the full width
                .background(isInverted ? .darkBlueGray : .softPeriwinkle)
                .cornerRadius(10)
        }
    }
}

#Preview {
    SubmitButton(title: "Test", isInverted: false, action: { print("Lubie pączki")})
}
