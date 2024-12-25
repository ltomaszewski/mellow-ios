//
//  SettingsManager.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 25/12/2024.
//

import Foundation

struct AppSettings: Codable {
    var deviceId: String
    var kidId: String
}

// MARK: - Settings Manager Actor
actor SettingsManager {
    
    // MARK: - Private Properties
    private var settings: AppSettings
    private let settingsFileURL: URL
    private var continuations: [UUID: AsyncStream<AppSettings>.Continuation] = [:]
    
    // MARK: - Initialization
    init() {
        // Determine the file URL for storing settings
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.settingsFileURL = documentsDirectory.appendingPathComponent("AppSettings.json")
        
        // Load settings from disk or initialize with default values
        if let data = try? Data(contentsOf: settingsFileURL),
           let loadedSettings = try? JSONDecoder().decode(AppSettings.self, from: data) {
            self.settings = loadedSettings
        } else {
            // Initialize with default settings
            self.settings = AppSettings(deviceId: UUID().uuidString,
                                        kidId: "")
            Task {
                await saveSettings()
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// Retrieves the current settings synchronously in a thread-safe manner.
    func getSettings() -> AppSettings {
        return settings
    }
    
    /// Retrieves the current settings asynchronously in a thread-safe manner.
    func getSettingsAsync() async -> AppSettings {
        return settings
    }
    
    /// Updates the settings with a new value in a thread-safe manner.
    func updateSettings(_ update: @escaping (inout AppSettings) -> Void) async {
        update(&settings)
        await saveSettings()
        await notifySubscribers()
    }
    
    /// Provides an AsyncStream to observe settings changes.
    func settingsUpdates() -> AsyncStream<AppSettings> {
        AsyncStream { continuation in
            // Generate a unique identifier for this continuation
            let id = UUID()
            
            Task {
                await self.addContinuation(id: id, continuation: continuation)
            }
            
            // Handle cancellation by removing the continuation using its UUID
            continuation.onTermination = { @Sendable _ in
                Task {
                    await self.removeContinuation(id: id)
                }
            }
        }
    }
    
    /// Resets settings in memory and removes the file from disk synchronously.
    func reset() {
        // Reset settings to default values
        settings = AppSettings(deviceId: self.settings.deviceId, kidId: "")
        
        // Remove settings file from disk
        do {
            try FileManager.default.removeItem(at: settingsFileURL)
        } catch {
            print("Failed to remove settings file: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    /// Saves the current settings to disk.
    private func saveSettings() async {
        do {
            let data = try JSONEncoder().encode(settings)
            try data.write(to: settingsFileURL, options: [.atomicWrite])
        } catch {
            print("Failed to save settings: \(error)")
        }
    }
    
    /// Notifies all subscribers about the updated settings.
    private func notifySubscribers() async {
        for continuation in continuations.values {
            continuation.yield(settings)
        }
    }
    
    /// Adds a new continuation to the subscribers list.
    private func addContinuation(id: UUID, continuation: AsyncStream<AppSettings>.Continuation) async {
        continuations[id] = continuation
        // Send the current settings immediately upon subscription
        continuation.yield(settings)
    }
    
    /// Removes a continuation from the subscribers list using its UUID.
    private func removeContinuation(id: UUID) async {
        continuations.removeValue(forKey: id)
    }
}
