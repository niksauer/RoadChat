//
//  AuthenticationManager.swift
//  RoadChat
//
//  Created by Niklas Sauer on 09.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import RoadChatKit

class AuthenticationManager {
    
    // MARK: - Public Static Properties
    static var activeUser: User?
    
    // MARK: - Public Properties
    let credentials = CredentialManager.shared
    let authenticationService = AuthenticationService(credentials: CredentialManager.shared)
    let userManager = UserManager()
    
    // MARK: - Public Methods
    func login(_ user: LoginRequest, completion: @escaping (User?, Error?) -> Void) {
        do {
            try authenticationService.login(user) { token, error in
                guard let token = token else {
                    // pass service error
                    log.error("Failed to login user: \(error!)")
                    completion(nil, error!)
                    return
                }
                
                do {
                    // save credentials
                    try self.credentials.setToken(token.token)
                    try self.credentials.setUserID(token.userID)
                    log.info("Successfully logged in user.")
                    
                    self.userManager.getUserById(token.userID) { user, error in
                        guard let user = user else {
                            // pass service / core data error
                            completion(nil, error!)
                            return
                        }
                        
                        // set active user
                        AuthenticationManager.activeUser = user
                        log.debug("Set currently active user '\(user.id)'.")
                        completion(user, nil)
                    }
                } catch {
                    // pass keychain error
                    log.error("Failed to save credentials to keychain: \(error)")
                    completion(nil, error)
                }
            }
        } catch {
            // pass body encoding error
            log.error("Failed to send 'LoginRequest': \(error)")
            completion(nil, error)
        }
    }
    
    func logout(completion: @escaping (Error?) -> Void) {
        authenticationService.logout { error in
            guard error == nil else {
                // pass service error
                log.error("Failed to log out user: \(error!)")
                completion(error!)
                return
            }
            
            do {
                // remove credentials
                try self.credentials.setToken(nil)
                try self.credentials.setUserID(nil)
                log.info("Successfully logged out user.")
                
                // unset active user
                AuthenticationManager.activeUser = nil
                log.debug("Unset currently active user.")
                completion(nil)
            } catch {
                // pass keychain error
                log.error("Failed to remove credentials from keychain: \(error)")
                completion(error)
            }
        }
    }

}
