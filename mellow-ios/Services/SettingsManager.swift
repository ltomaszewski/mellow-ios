//
//  SettingsManager.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 25/12/2024.
//

import Foundation
import SwiftData
import SwiftlyBeautiful

@Model
@Printable
@SwiftDataCRUD
class AppSettings {
    var id: String = UUID().uuidString
    var deviceId: String = ""
    var kidId: String = ""

    init(deviceId: String = UUID().uuidString, kidId: String = "") {
        self.id = UUID().uuidString
        self.deviceId = deviceId
        self.kidId = kidId
    }
}
final class SettingsManager {
    // MARK: - Public Methods
    
    /// Retrieves the current settings or initializes default settings if not present.
    func getSettings(context: ModelContext) -> AppSettings {
        if let existingSettings = try? AppSettings.query(sortBy: [], context: context).first {
            return existingSettings
        } else {
            let defaultSettings = AppSettings()
            try? AppSettings.save(defaultSettings, context: context)
            return defaultSettings
        }
    }

    /// Updates the settings with a new value.
    func updateSettings(context: ModelContext, update: (inout AppSettings) -> Void) {
        if let existingSettings = try? AppSettings.query(sortBy: [], context: context).first {
            try? AppSettings.update(id: existingSettings.id,
                                    updateClosure: update,
                                    context: context)
        } else {
            let defaultSettings = AppSettings()
            try? AppSettings.save(defaultSettings, context: context)
            try? AppSettings.update(id: defaultSettings.id,
                                    updateClosure: update,
                                    context: context)
        }

    }

    /// Resets settings to default values.
    func reset(context: ModelContext) {
        guard let existingSettings = try? AppSettings.query(sortBy: [], context: context).first else {
            fatalError("AppSettings not found")
        }
        try? AppSettings.delete(existingSettings, context: context)
        try? AppSettings.save(AppSettings(), context: context)
    }
}
