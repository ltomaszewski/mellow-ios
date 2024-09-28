//
//  AddSleepSessionDeleteView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 28/09/2024.
//

import SwiftUI

extension AddSleepView {
    struct SessionDelete: View {
        @Binding var session: SleepSession?
        @Binding var isPresented: Bool
        var presentationMode: Binding<PresentationMode>
        @EnvironmentObject var databaseStore: DatabaseStore
        @Environment(\.modelContext) var modelContext

        var body: some View {
            VStack(spacing: 16) {
                CalendarSeparator()
                HStack {
                    Text("Delete")
                        .font(.main16)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Button {
                        databaseStore.deleteSleepSession(id: session!.id,
                                                         context: modelContext)
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
