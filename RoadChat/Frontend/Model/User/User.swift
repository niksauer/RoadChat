//
//  User.swift
//  RoadChat
//
//  Created by Niklas Sauer on 02.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import CoreData
import RoadChatKit

class User: NSManagedObject {
    
    static func create(_ user: RegisterRequest, completion: @escaping (Error?) -> Void) {
        let userService = UserService()
        
        do {
            try userService.create(user) { user, error in
                guard let user = user else {
                    completion(error!)
                    return
                }
                
                do {
                    try CredientialManager.shared.setUserID(user.id)
                } catch {
                    // pass keychain error
                    completion(error)
                }
            }
        } catch {
            // pass body encoding error
            completion(error)
        }
    }
    
    static func login(_ user: LoginRequest, completion: @escaping (Error?) -> Void) {
        let loginClient = LoginService()
        
        do {
            try loginClient.login(user) { token, error in
                guard let token = token else {
                    completion(error!)
                    return
                }
                
                do {
                    try CredientialManager.shared.setToken(token.token)
                    try CredientialManager.shared.setUserID(token.userID)
                    completion(nil)
                } catch {
                    // pass keychain error
                    completion(error)
                }
            }
        } catch {
            // pass body encoding error
            completion(error)
        }
    }

}
