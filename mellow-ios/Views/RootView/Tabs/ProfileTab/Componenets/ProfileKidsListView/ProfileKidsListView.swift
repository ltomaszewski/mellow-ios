//
//  ProfileKidsListView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 09/11/2024.
//

import SwiftUI
import SwiftData

struct ProfileKidsListView: View {
    @Query(sort: \Kid.dateOfBirth) var kids: [Kid]
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appStateStore: AppState.Store
    @State var selectedKid: Kid?
    
    var body: some View {
        VStack(spacing: 0) {
            Image(.whiteBar)
                .padding(.top, 16)
                .padding(.bottom, 8)

            Text("Select Child")
                .font(.main18)
                .foregroundStyle(.white)
                .padding(.vertical, 16)
            
            List(selection: $selectedKid) {
                ForEach(kids, id: \.name) { kid in
                    ProfileKidListItemView(kid: kid, isSelected: kid == selectedKid)
                        .contentShape(Rectangle()) // Makes the entire row tappable
                        .onTapGesture {
                            selectedKid = kid
                            appStateStore.dispatch(.setSelectedKid(kid, modelContext))
                        }
                        .background(Color.gunmetalBlue)
                        .listRowInsets(EdgeInsets())
                }
            }
            .listStyle(.plain)
            .scrollDisabled(true)
        }
        .background(Color.gunmetalBlue)
        .scrollDisabled(true)
        .onAppear {
            selectedKid = appStateStore.state.selectedKid
        }
    }
}

//#Preview {
//    // Mock data for kids
//    @Previewable @State var selectedKid: ProfileKidsListView.Kid? = nil
//    // Mock data for kids
//    let mockKids = [
//        ProfileKidsListView.Kid(
//            name: "Lukasz",
//            ageFormatted: "3 years 6 months",
//            imageResource: .kidoHim,
//            databaseKidsID: "1"
//        ),
//        ProfileKidsListView.Kid(
//            name: "Anna",
//            ageFormatted: "5 years",
//            imageResource: .kidoHer,
//            databaseKidsID: "2"
//        ),
//        ProfileKidsListView.Kid(
//            name: "Mia",
//            ageFormatted: "4 years 2 months",
//            imageResource: .kidoHer,
//            databaseKidsID: "3"
//        )
//    ]
//    
//    ProfileKidsListView(
//        kids: .constant(mockKids),
//        selectedKid: $selectedKid
//    )
//    .padding()
//    .background(Color.gray.opacity(0.2)) // Optional: Add a background for better visibility
//}
