//
//  DimmedBackgroundViewModifier.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 26/09/2024.
//

import SwiftUI

struct DimmedBackgroundViewModifier: ViewModifier {
    @Binding var isPresented: Bool
    @State private var showDimmedBackground = false

    func body(content: Content) -> some View {
        ZStack {
            content
            //.blur(radius: showDimmedBackground ? 3 : 0) // Blur adds white edges, for unkown reason so its worth it to investage
            if showDimmedBackground {
                Color.black
                    .opacity(0.4) // Adjust opacity to change the dimming level
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
            }
        }
        .onChange(of: isPresented) { _, newValue in
            withAnimation(.easeOut) {
                showDimmedBackground = newValue
            }
        }
    }
}

extension View {
    func dimmedBackground(isPresented: Binding<Bool>) -> some View {
        self.modifier(DimmedBackgroundViewModifier(isPresented: isPresented))
    }
}
