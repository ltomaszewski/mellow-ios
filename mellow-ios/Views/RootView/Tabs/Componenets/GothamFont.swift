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
