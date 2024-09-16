//
//  SFFont.swift
//  Kidsy-iOS
//
//  Created by Lukasz Tomaszewski on 29/04/2024.
//

import SwiftUI

extension Font {
    private static let fontName = "Gotham Rounded"
    public static var main10: Font {
        .custom(fontName, fixedSize: 10)
    }
    
    public static var main12: Font {
        .custom(fontName, fixedSize: 12)
    }
    
    public static var main14: Font {
        .custom(fontName, fixedSize: 14)
    }
    
    public static var main16: Font {
        .custom(fontName, fixedSize: 16)
    }
    
    public static var main18: Font {
        .custom(fontName, fixedSize: 18)
    }
    
    public static var main20: Font {
        .custom(fontName, fixedSize: 20)
    }
    
    public static var main22: Font {
        .custom(fontName, fixedSize: 22)
    }
    
    public static var main24: Font {
        .custom(fontName, fixedSize: 24)
    }
    
    public static var main26: Font {
        .custom(fontName, fixedSize: 26)
    }
    
    public static var main64: Font {
        .custom(fontName, fixedSize: 64)
    }
}

struct KidsyColors {
    fileprivate init() {}
    public static let mintGreen = Color(hex: "#37C882")   // A vibrant, minty green
    public static let paleGray = Color(hex: "#F2F2F2")   // A very light, almost white gray
    public static let mediumGray = Color(red: 0.4588235294117647, green: 0.4588235294117647, blue: 0.4588235294117647) // A neutral, medium gray
    public static let softSkyBlue = Color(red: 142/255, green: 150/255, blue: 212/255) // A gentle and airy blue reminiscent of a serene sky
}

extension Color {
    static var kidsy: KidsyColors = KidsyColors()
    
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")

        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
