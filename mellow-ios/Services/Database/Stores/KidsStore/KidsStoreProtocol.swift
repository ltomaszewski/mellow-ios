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
    var kids: CurrentValueSubject<[Kid], Never> { get }
    
    func addKid(name: String, dateOfBirth: Date, context: ModelContext) throws -> Kid
    func loadKids(context: ModelContext) throws -> [Kid]
    func removeKid(_ kid: Kid, context: ModelContext) throws
}
