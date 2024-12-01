//
//  KidsStoreProtocol.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 20/10/2024.
//

import Foundation
import Combine
import SwiftData

protocol KidsStoreProtocol {    
    func add(name: String, dateOfBirth: Date, context: ModelContext) throws -> Kid
    func load(context: ModelContext) throws -> [Kid]
    func remove(_ kid: Kid, context: ModelContext) throws
    func removeAll(context: ModelContext) throws // Updated for clarity
}
