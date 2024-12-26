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
final class SettingsManager {
    
    // MARK: - Private Properties
    private var settings: AppSettings
    private let settingsFileURL: URL
    
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
            saveSettings()
        }
    }
    
    // MARK: - Public Methods
    
    /// Retrieves the current settings synchronously in a thread-safe manner.
    func getSettings() -> AppSettings {
        return settings
    }
    
    /// Updates the settings with a new value in a thread-safe manner.
    func updateSettings(_ update: @escaping (inout AppSettings) -> Void) {
        update(&settings)
        saveSettings()
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
    private func saveSettings() {
        do {
            let data = try JSONEncoder().encode(settings)
            try data.write(to: settingsFileURL, options: [.atomicWrite])
        } catch {
            print("Failed to save settings: \(error)")
        }
    }
}
