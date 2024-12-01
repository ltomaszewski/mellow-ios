//
//  KidsStore.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 20/10/2024.
//

import Foundation
import SwiftData
import Combine

struct KidsStore: KidsStoreProtocol {
    
    func add(name: String,
             dateOfBirth: Date,
             sleepTime: Date,
             wakeTime: Date,
             context: ModelContext) throws -> Kid {
        let newKid = Kid(name: name, dateOfBirth: dateOfBirth, sleepTime: sleepTime, wakeTime: wakeTime)
        try Kid.save(newKid, context: context)
        return newKid
    }
    
    func load(context: ModelContext) throws -> [Kid] {
        let loadedKids = try Kid.query(predicate: nil, sortBy: [], context: context)
        return loadedKids
    }
    
    func remove(_ kid: Kid, context: ModelContext) throws {
        try Kid.delete(kid, context: context)
    }
    
    func removeAll(context: ModelContext) throws {
        let allKids = try Kid.query(predicate: nil, sortBy: [], context: context)
        for kid in allKids {
            try Kid.delete(kid, context: context)
        }
    }
    
    func update(kid: Kid, name: String, dateOfBirth: Date, context: ModelContext) throws {
        
        // Save the changes to the context
        try Kid.update(id: kid.id,
                       updateClosure: { kid in
            // Update the kid's properties
            kid.name = name
            kid.dateOfBirth = dateOfBirth
        }, context: context)
    }
}
