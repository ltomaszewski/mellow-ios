//
//  PageViewContent.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 19/08/2024.
//

import SwiftUI


// A SwiftUI view that creates and manages a UIPageViewController
struct PageViewContent<V: View, I: Hashable>: UIViewControllerRepresentable {
    let startIndex: I
    var getCurrentIndex: (_ view: V) -> I
    var nextIndex: (_ lastIndex: I) -> I
    var previousIndex: (_ lastIndex: I) -> I
    var viewBuilder: (_ index: I) -> V
    var hasNextPage: () -> Bool
    var hasPreviousPage: () -> Bool
    var indexHasChanged: (I) -> Void

    // Create and configure the UIPageViewController
    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        
        pageViewController.dataSource = context.coordinator
        pageViewController.delegate = context.coordinator
        
        let viewController = viewBuilder(startIndex).viewController()
        pageViewController.setViewControllers([viewController], direction: .forward, animated: false)
        pageViewController.view.backgroundColor = .clear
        
        return pageViewController
    }

    
    // Update the UIPageViewController in response to state changes
    func updateUIViewController(_ uiViewController: UIPageViewController, context: Context) {
        // Optionally, update the view controllers if your model changes
//        print("updateUIViewController")
    }
    
    // Coordinator to manage the data source and delegate methods
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: PageViewContent
        
        init(_ pageViewContent: PageViewContent) {
            self.parent = pageViewContent
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard parent.hasPreviousPage() else {
                return nil
            }
            
            guard let hostingViewController = viewController as? UIHostingController<V> else {
                return nil
            }
            let rootView = hostingViewController.rootView
            let index = parent.getCurrentIndex(rootView)
            let indexBefore = parent.previousIndex(index)
            return parent.viewBuilder(indexBefore).viewController()
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard parent.hasNextPage() else {
                return nil
            }
            
            guard let hostingViewController = viewController as? UIHostingController<V> else {
                return nil
            }
            let rootView = hostingViewController.rootView
            let index = parent.getCurrentIndex(rootView)
            let indexBefore = parent.nextIndex(index)
            return parent.viewBuilder(indexBefore).viewController()
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            guard completed, let hostingViewController = pageViewController.viewControllers?.first as? UIHostingController<V> else { return }
            let rootView = hostingViewController.rootView
            let index = parent.getCurrentIndex(rootView)
            parent.indexHasChanged(index)
        }
    }
}


fileprivate extension View {
    func viewController() -> UIViewController {
        let viewController = UIHostingController(rootView: self)
        viewController.view.backgroundColor = .clear
        return viewController
    }
}
