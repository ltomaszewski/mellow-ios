//
//  RoundedCorner.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 30/10/2024.
//

import SwiftUI

struct RoundedCorner: InsettableShape {
    var radius: CGFloat
    var corners: UIRectCorner
    var insetAmount: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        // Adjust the rect for the inset amount
        let insetRect = rect.insetBy(dx: insetAmount, dy: insetAmount)
        
        // Create the rounded corner path
        let path = UIBezierPath(
            roundedRect: insetRect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        
        return Path(path.cgPath)
    }
    
    // Required method for InsettableShape
    func inset(by amount: CGFloat) -> some InsettableShape {
        var roundedCorner = self
        roundedCorner.insetAmount += amount
        return roundedCorner
    }
}
