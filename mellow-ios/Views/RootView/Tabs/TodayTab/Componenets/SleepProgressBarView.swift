//
//  SleepProgressBarView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 12/10/2024.
//

import SwiftUI

public struct SleepProgressBarView: View {
    var progress: Float // Value between 0 and 1
    
    public var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.darkBlueGray)
            .overlay {
                GeometryReader { geometry in
                    // Progress fill
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.softPeriwinkle)
                        .frame(width: CGFloat(progress) * geometry.size.width) // Adjust width as per progress
                }
            }
    }
}

#Preview {
    SleepProgressBarView(progress: 0.4)
}
