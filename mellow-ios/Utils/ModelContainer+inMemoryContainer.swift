//
//  ModelContainer+.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 04/12/2024.
//

import SwiftData

extension ModelContainer {
    static func inMemoryContainer(for models: any PersistentModel.Type) -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        do {
            return try ModelContainer(for: models, configurations: configuration)
        } catch {
            fatalError("Failed to create in-memory ModelContainer: \(error)")
        }
    }
}
