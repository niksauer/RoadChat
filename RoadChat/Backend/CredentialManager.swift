//
//  ClientCredentialStore.swift
//  RoadChat
//
//  Created by Niklas Sauer on 07.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import Locksmith

enum CredentialError: Error {
    case noUserIDSet
}

struct CredentialManager: APICredentialStore {
    
    private enum keys: String {
        case userID
        case accessToken
    }
    
    private var userAccount = "RoadChatUser"
    
    private init() {}

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
    
    static var shared = CredentialManager()
    
    func getUserID() -> Int? {
        return getValue(for: keys.userID.rawValue) as? Int
    }
    
    func setUserID(_ userID: Int?) throws {
        try setValue(userID as Any, for: keys.userID.rawValue)
    }
    
    func getToken() -> String? {
        return getValue(for: keys.accessToken.rawValue) as? String
    }
    
    func setToken(_ token: String?) throws {
        try setValue(token as Any, for: keys.accessToken.rawValue)
    }
    
}
