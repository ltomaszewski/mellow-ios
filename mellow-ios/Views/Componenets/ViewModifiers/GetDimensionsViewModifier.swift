//
//  GetDimensionsModifier.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 25/09/2024.
//

import SwiftUI

struct GetDimensionsViewModifier: ViewModifier {
    @Binding var width: CGFloat
    @Binding var height: CGFloat
    
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

extension View {
    func getSize(_ width: Binding<CGFloat>, _ height: Binding<CGFloat>) -> some View {
        self.modifier(GetDimensionsViewModifier(width: width, height: height))
    }
}
