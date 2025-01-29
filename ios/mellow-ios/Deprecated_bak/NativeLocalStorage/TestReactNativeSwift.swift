//
//  TestReactNativeSwiftFile.h
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 28/01/2025.
//

import Foundation

@objcMembers
public class TestReactNativeSwift: NSObject {
    
    // MARK: - Shared Instance
    
    /// The static (singleton) instance of `TestReactNativeSwift`.
    /// The static let property in Swift is lazily initialized and thread-safe.
    private static let sharedInstance = TestReactNativeSwift()
    
    /// Provide an Objective-C-accessible class method to retrieve the singleton.
    /// In Swift, you can call `TestReactNativeSwift.shared()` or directly
    /// access the property (e.g., `TestReactNativeSwift.sharedInstance`).
    @objc public class func shared() -> TestReactNativeSwift {
        return sharedInstance
    }
    
    // MARK: - Initializer
    
    /// Make the initializer private so that it cannot be directly instantiated outside.
    private override init() {
        super.init()
        // Any custom setup can be done here.
    }
    
    // MARK: - Public Methods
    
    /// A sample method to demonstrate functionality.
    public func test() -> String {
        return "Lubie jak test dziala!"
    }
}
