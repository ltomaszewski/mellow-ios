//
//  RTNCalculator.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 28/01/2025.
//

import Foundation

@objcMembers
public class RNTestEmiter: NSObject {

    // MARK: - Singleton
    public static let shared = RNTestEmiter()

    // MARK: - Private Properties
    private var counter: Int = 0
    private var timer: Timer?
    
    /// A concurrent queue or a serial queue used to synchronize access to
    /// `counter`, `timer`, and `observers`.
    private let lockQueue = DispatchQueue(label: "com.example.RNTestEmiter.lockQueue")

    /// Observers are stored in a dictionary keyed by UUID for easy addition/removal.
    private var observers = [UUID: (Int) -> Void]()

    // MARK: - Init
    override private init() {
        super.init()
        // If you want the timer to start immediately when the singleton is created, keep this:
        startTimer()
        // Otherwise, you can comment out startTimer() here,
        // and let the user explicitly call startTimer() when needed.
    }

    // MARK: - Timer Control
    public func startTimer() {
        timer?.invalidate()
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            timer = Timer.scheduledTimer(timeInterval: 1.0,
                                         target: self,
                                         selector: #selector(timerFired),
                                         userInfo: nil,
                                         repeats: true)
        }
    }

    public func stopTimer() {
        lockQueue.sync {
            timer?.invalidate()
            timer = nil
        }
    }

    @objc private func timerFired() {
        counter += 1
        notifyObservers(with: counter)
    }

    // MARK: - Observers
    /// Register an observer block that will be called with the updated counter value.
    /// - Returns: A UUID that can be used to remove the observer later.
    public func registerObserver(_ observer: @escaping (Int) -> Void) -> UUID {
        let id = UUID()
        observers[id] = observer
        return id
    }

    /// Remove an observer using its UUID.
    public func removeObserver(_ id: UUID) {
        _ = lockQueue.sync {
            observers.removeValue(forKey: id)
        }
    }

    /// Notifies all registered observers with the current counter value.
    private func notifyObservers(with value: Int) {
        // Copy observers to avoid potential re-entrancy issues if observers add/remove themselves.
        let currentObservers = lockQueue.sync { observers.values }
        currentObservers.forEach { $0(value) }
    }
}
