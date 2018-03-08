//
//  ClientCredentialStore.swift
//  RoadChat
//
//  Created by Niklas Sauer on 07.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import Locksmith

struct CredientialManager: APICredentialStore {
    static var shared = CredientialManager()
    
    private init() {}
    
    var userID: Int?
    
    func getToken() -> String? {
        if let dictionary = Locksmith.loadDataForUserAccount(userAccount: "RoadChatUser") {
            return dictionary["AccessToken"] as? String
        } else {
            return nil
        }
    }
    
    func setToken(_ token: String) throws {
         try Locksmith.updateData(data: ["AccessToken": token as Any], forUserAccount: "RoadChatUser")
    }
}
