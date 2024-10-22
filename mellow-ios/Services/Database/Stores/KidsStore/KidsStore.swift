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
    let kids: CurrentValueSubject<[Kid], Never> = .init([])

    func addKid(name: String, dateOfBirth: Date, context: ModelContext) throws -> Kid {
        let newKid = Kid(name: name, dateOfBirth: dateOfBirth)
        try Kid.save(newKid, context: context)
        var updatedKids = kids.value
        updatedKids.append(newKid)
        kids.send(updatedKids)
        return newKid
    }

    func loadKids(context: ModelContext) throws -> [Kid] {
        let loadedKids = try Kid.query(predicate: nil, sortBy: [], context: context)
        kids.send(loadedKids)
        return loadedKids
    }

    func removeKid(_ kid: Kid, context: ModelContext) throws {
        try Kid.delete(kid, context: context)
        var updatedKids = kids.value
        if let index = updatedKids.firstIndex(where: { $0.id == kid.id }) {
            updatedKids.remove(at: index)
        }
        kids.send(updatedKids)
    }
}
