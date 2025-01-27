//
//  ObservableWrapper.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 26/01/2025.
//

import Foundation

/// A generic wrapper that makes any type T usable with SwiftUI's EnvironmentObject and StateObject/ObservedObject.
/// Now supports a no-argument init (stores an optional) and provides an update method.
final class ObservableWrapper<T>: ObservableObject {
    
    /// Using @Published so that SwiftUI views automatically update when 'value' changes
    @Published private(set) var value: T?
    
    /// Initialize with no argument (the internal value is nil by default).
    init() {
        self.value = nil
    }
    
    /// Initialize with an existing value of type T.
    init(_ value: T) {
        self.value = value
    }
    
    /// Update the wrapped value at any time, which will notify SwiftUI views to refresh.
    func update(_ newValue: T) {
        self.value = newValue
    }
}
