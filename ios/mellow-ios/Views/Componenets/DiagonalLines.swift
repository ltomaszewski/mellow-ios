//
//  DiagonalLines.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 30/10/2024.
//

import SwiftUI

struct DiagonalLines: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let lineSpacing: CGFloat = 40
        let lineWidth = rect.width + rect.height
        
        // Draw mirrored diagonal lines
        var xOffset: CGFloat = 0
        while xOffset < lineWidth {
            path.move(to: CGPoint(x: rect.width - xOffset, y: 0))
            path.addLine(to: CGPoint(x: rect.width - xOffset + rect.height, y: rect.height))
            xOffset += lineSpacing
        }
        
        return path
    }
}
