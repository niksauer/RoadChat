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
    
    static func login(_ request: LoginRequest, completion: @escaping (Error?) -> Void) {
        let loginClient = LoginService()
        
        do {
            try loginClient.login(request) { token, error in
                guard let token = token else {
                    completion(error!)
                    return
                }
                
                do {
                    try CredientialManager.shared.setToken(token.token)
//                    try CredientialManager.shared.setUserID(token.userID)
                    completion(nil)
                } catch {
                    // handle keychain error
                    completion(error)
                }
            }
        } catch {
            // handle body encoding error
            completion(error)
        }
    }

}
