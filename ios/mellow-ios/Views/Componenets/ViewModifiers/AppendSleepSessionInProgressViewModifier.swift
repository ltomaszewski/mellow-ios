//
//  AppendSleepSessionInProgressViewModifier.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 02/11/2024.
//

import SwiftUI

struct AppendSleepSessionInProgressViewModifier<SleepSessionInProgressView: View>: ViewModifier {
    @Binding var sleepSessionInProgress: SleepSessionViewRepresentation?
    let view: SleepSessionInProgressView
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if sleepSessionInProgress != nil {
                VStack(spacing: 0) {
                    Spacer()
                    view
                }
            }
        }
    }
}

extension View {
    func showInProgressBarViewIfNeeded<SleepSessionInProgressView: View>(_ sleepSessionInProgress: Binding<SleepSessionViewRepresentation?>,
                                                                         view: SleepSessionInProgressView) -> some View {
        self.modifier(AppendSleepSessionInProgressViewModifier(sleepSessionInProgress: sleepSessionInProgress,
                                                     view: view))
    }
}
