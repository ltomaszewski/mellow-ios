//
//  AppState+CloudKit.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 05/01/2025.
//

import CloudKit

extension AppState.Reducer {
    func isCloudKitSyncComplete(completion: @escaping (Bool) -> Void) {
        let container = CKContainer.default()
        container.accountStatus { (status: CKAccountStatus, error: Error?) in
            if let error = error {
                print("Error checking CloudKit account status: \(error.localizedDescription)")
                completion(false)
                return
            }
            guard status == .available else {
                print("CloudKit is not available: \(status.rawValue)")
                completion(false)
                return
            }

            let operation = CKFetchDatabaseChangesOperation(previousServerChangeToken: nil)
            operation.fetchDatabaseChangesResultBlock = { result in
                switch result {
                case .success(let (serverChangeToken, moreComing)):
                    print("CloudKit sync complete with token: \(serverChangeToken), moreComing: \(moreComing)")
                    completion(!moreComing) // Complete only when all changes are fetched
                case .failure(let error):
                    print("Error fetching database changes: \(error.localizedDescription)")
                    completion(false)
                }
            }
            container.privateCloudDatabase.add(operation)
        }
    }
}
