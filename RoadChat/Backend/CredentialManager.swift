//
//  ClientCredentialStore.swift
//  RoadChat
//
//  Created by Niklas Sauer on 07.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import Locksmith

struct CredentialManager: APICredentialStore {

    private var userAccount = "RoadChatUser"
    
    private init() {}

    private func getValue(for key: String) -> Any? {
        return Locksmith.loadDataForUserAccount(userAccount: userAccount)?[key]
    }
    
    private func setValue(_ value: Any, for key: String) throws {
        try Locksmith.updateData(data: [key: value], forUserAccount: userAccount)
    }
    
    static var shared = CredientialManager()
    
    func getUserID() -> Int? {
        return getValue(for: "UserID") as? Int
    }
    
    func setUserID(_ userID: Int) throws {
        try setValue(userID, for: "UserID")
    }
    
    func getToken() -> String? {
        return getValue(for: "AccessToken") as? String
    }
    
    func setToken(_ token: String) throws {
        try setValue(token, for: "AccessToken")
    }
    
}
