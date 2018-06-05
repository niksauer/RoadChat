//
//  ClientCredentialStore.swift
//  RoadChat
//
//  Created by Niklas Sauer on 07.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import Locksmith

struct KeychainManager: APICredentialStore {
    
    // MARK: - Singleton
    static var shared = KeychainManager()

    // MARK: - Private Properties
    private let userAccount = "RoadChat"
    
    private enum Keys {
        static let UserID = "userID"
        static let AccessToken = "accessToken"
    }
    
    // MARK: - Initialization
    private init() {}

    // MARK: - Private Methods
    private func getValue(for key: String) -> Any? {
        return Locksmith.loadDataForUserAccount(userAccount: userAccount)?[key]
    }
    
    private func setValue(_ value: Any, for key: String) throws {
        if var dataDictionary = Locksmith.loadDataForUserAccount(userAccount: userAccount) {
            dataDictionary[key] = value
            try Locksmith.updateData(data: dataDictionary, forUserAccount: userAccount)
        } else {
            try Locksmith.saveData(data: [key: value], forUserAccount: userAccount)
        }
    }
    
    // MARK: - APICredentialStore Protocol
    func getUserID() -> Int? {
        return getValue(for: Keys.UserID) as? Int
    }
    
    func setUserID(_ userID: Int?) throws {
        try setValue(userID as Any, for: Keys.UserID)
    }
    
    func getToken() -> String? {
        return getValue(for: Keys.AccessToken) as? String
    }
    
    func setToken(_ token: String?) throws {
        try setValue(token as Any, for: Keys.AccessToken)
    }
    
    func reset() throws {
        try setToken(nil)
        try setUserID(nil)
    }

}
