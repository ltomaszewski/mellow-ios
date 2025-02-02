//
//  LearnConnector.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 29/01/2025.
//
import SwiftUI

@objcMembers
final class LearnConnector: NSObject, ObservableObject {
    static let shared = LearnConnector()
    private var resetHandler: (() -> Void)?
    
    @Published var courseInProgress: Bool = false
    
    private override init() {}
    
    public func onCourseStarted() {
        DispatchQueue.main.async { [weak self] in
            self?.courseInProgress = true
        }
    }
    
    public func onCourseEnded() {
        DispatchQueue.main.async { [weak self] in
            self?.courseInProgress = false
        }
    }
    
    public func resetState() {
        guard let resetHandler else {
            fatalError("Setup reset handler first")
        }
        resetHandler()
    }
    
    public func setResetHandler(_ handler: @escaping () -> Void) {
        self.resetHandler = handler
    }
}
