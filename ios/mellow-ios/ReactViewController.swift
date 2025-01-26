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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Build the custom view
        let mainView = contentViewBuilder()
        mainView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add to controller’s view hierarchy
        view.addSubview(mainView)
        
        // Pin edges to take the full space of the view controller
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: view.topAnchor),
            mainView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
