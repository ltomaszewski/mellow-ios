//
//  ReactViewController.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 21/01/2025.
//

import SwiftUI
import UIKit
import React_RCTAppDelegate

struct ReactView: UIViewControllerRepresentable {
    var moduleName: String
    var rootViewFactory: RCTRootViewFactory
    
    func makeUIViewController(context: Context) -> UIReactNativeHostingController {
        UIReactNativeHostingController { rootViewFactory.view(withModuleName: moduleName) }
    }

    func updateUIViewController(_ uiViewController: UIReactNativeHostingController, context: Context) { }
}

class UIReactNativeHostingController: UIViewController {
    
    private let contentViewBuilder: () -> UIView
    
    // MARK: - Initialization
    
    init(contentViewBuilder: @escaping () -> UIView) {
        self.contentViewBuilder = contentViewBuilder
        super.init(nibName: nil, bundle: nil)
    }
    
    // If you’re using storyboards (likely not here), you’d need this init as well.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        // Make your custom view the controller’s main view
        view = contentViewBuilder()
    }
}
