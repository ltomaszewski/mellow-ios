//
//  ReducerProtocol.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 01/12/2024.
//

// Main protocol for reducer for easier mocking and access isolation
protocol ReducerProtocol {
    associatedtype ReducerState
    associatedtype ReducerAction

    func reduce(state: inout ReducerState, action: ReducerAction)
}
