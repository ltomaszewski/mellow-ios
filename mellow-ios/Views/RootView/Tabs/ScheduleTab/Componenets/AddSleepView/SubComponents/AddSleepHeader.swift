//
//  AddSleepHeaderView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 28/09/2024.
//

import SwiftUI

extension AddSleepView {
    struct HeaderView: View {
        @Binding var isPresented: Bool
        var presentationMode: Binding<PresentationMode>
        var saveAction: () -> Void

        var body: some View {
            HStack {
                Button("Cancel") {
                    isPresented = false
                    presentationMode.wrappedValue.dismiss()
                }
                .font(.main16)
                .foregroundStyle(Color.softPeriwinkle)

                Spacer()

                Button("Save") {
                    saveAction()
                }
                .font(.main16)
                .foregroundStyle(Color.softPeriwinkle)
            }
        }
    }
}
