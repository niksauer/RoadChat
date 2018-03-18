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
    
    // MARK: - Public Properties
    let credentials: APICredentialStore
    let authenticationService: AuthenticationService
    
    var activeUser: User?
    
    // MARK: - Initialization
    init(credentials: APICredentialStore) {
        self.credentials = credentials
        self.authenticationService = AuthenticationService(credentials: credentials)
    }
    
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
                    
                    User.getById(token.userID) { user, error in
                        guard let user = user else {
                            // pass service / core data error
                            completion(nil, error!)
                            return
                        }
                        
                        // set active user
                        self.activeUser = user
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
                self.activeUser = nil
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
