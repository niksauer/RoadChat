//
//  AuthenticationManager.swift
//  RoadChat
//
//  Created by Niklas Sauer on 09.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import RoadChatKit

struct AuthenticationManager {
    
    func login(_ user: LoginRequest, completion: @escaping (Error?) -> Void) {
        let loginClient = LoginService()
        
        do {
            try loginClient.login(user) { token, error in
                guard let token = token else {
                    // pass service error
                    log.error("Failed to login user: \(error!)")
                    completion(error!)
                    return
                }
                
                do {
                    try CredentialManager.shared.setToken(token.token)
                    try CredentialManager.shared.setUserID(token.userID)
                    log.info("Successful login.")
                    completion(nil)
                } catch {
                    // pass keychain error
                    log.error("Failed to save credentials to keychain: \(error)")
                    completion(error)
                }
            }
        } catch {
            // pass body encoding error
            log.error("Failed to send login request: \(error)")
            completion(error)
        }
    }
    
    func logout(completion: @escaping (Error?) -> Void) {
        let loginClient = LoginService()
        
        loginClient.logout { error in
            guard error == nil else {
                // pass service error
                completion(error!)
                return
            }
            
            do {
                try CredentialManager.shared.setToken(nil)
                try CredentialManager.shared.setUserID(nil)
                completion(nil)
            } catch {
                // pass keychain error
            }
        }
    }
    
}
