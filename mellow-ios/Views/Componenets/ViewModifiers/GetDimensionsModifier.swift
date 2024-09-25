//
//  GetDimensionsModifier.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 25/09/2024.
//

import SwiftUI

struct GetDimensionsModifier: ViewModifier {
    @Binding var height: CGFloat
    @Binding var width: CGFloat
    
    func body(content: Content) -> some View {
        content.background(
            GeometryReader { geo -> Color in
                height = geo.size.height
                width = geo.size.width
                return Color.clear
            }
        )
    }
}
