//
//  AddSleepSessionDeleteView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 28/09/2024.
//

import SwiftUI

extension AddSleepView {
    struct SessionDelete: View {
        @Environment(\.modelContext) var modelContext
        @EnvironmentObject var appStateStore: AppState.Store

        let session: SleepSessionViewRepresentation?
        var presentationMode: Binding<PresentationMode>

        var body: some View {
            VStack(spacing: 16) {
                CalendarSeparator()
                HStack {
                    Text("Delete")
                        .font(.main16)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Button {
                        appStateStore.dispatch(.sleepSessionOperation(.delete(session!.id), nil, modelContext))
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(.trash)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}
