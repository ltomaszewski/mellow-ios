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
        @EnvironmentObject var appStateStore: RAppState.Store

        @Binding var session: SleepSessionViewRepresentation?
        @Binding var isPresented: Bool
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
                        session = nil
                        isPresented = false
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
