//
//  SettingsManagerTests.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 25/12/2024.
//

import Testing
import Foundation
@testable import mellow_ios

@MainActor
class SettingsManagerTests {
    
    private var settingsManager: SettingsManager!
    
    init() async {
        // Initialize SettingsManager and reset to default settings
        settingsManager = SettingsManager.shared
        await settingsManager.updateSettings { settings in
            settings.kidId = ""
        }
    }
    
    deinit {
        // Reset to default settings after each test
        settingsManager = nil
    }
    
    func testDefaultSettings() async {
        let settings = await settingsManager.getSettings()
        #expect(settings.kidId == "")
    }
    
    func testUpdateSettings() async {
        await settingsManager.updateSettings { settings in
            settings.kidId = "12345"
        }
        
        let updatedSettings = await settingsManager.getSettings()
        #expect(updatedSettings.kidId == "12345")
    }
    
    func testSettingsPersistence() async {
        // Update settings
        await settingsManager.updateSettings { settings in
            settings.kidId = "persistentKidId"
        }
        
        // Simulate a new instance loading from disk
        let newManager = SettingsManager.shared
        let loadedSettings = await newManager.getSettings()
        
        // Validate that the settings persisted
        #expect(loadedSettings.kidId == "persistentKidId")
    }
    
    func testSettingsStream() async {
        var updates: [AppSettings] = []
        
        // Subscribe to settings updates
        let task = Task {
            for await updatedSettings in await settingsManager.settingsUpdates() {
                updates.append(updatedSettings)
                if updates.count == 2 { break }
            }
        }
        
        // Simulate a settings update
        await settingsManager.updateSettings { settings in
            settings.kidId = "streamedKidId"
        }
        
        // Wait for the subscription to complete
        await task.value
        
        // Assert initial and updated values
        #expect(updates.count == 2)
        #expect(updates[0].kidId == "")
        #expect(updates[1].kidId == "streamedKidId")
    }
}
