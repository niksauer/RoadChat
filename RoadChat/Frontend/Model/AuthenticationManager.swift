//
//  AuthenticationManager.swift
//  RoadChat
//
//  Created by Niklas Sauer on 09.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import RoadChatKit
import CoreData

class AuthenticationManager {
    
    // MARK: - Private Properties
    private let credentials: APICredentialStore
    private let authenticationService: AuthenticationService
    private let userManager: UserManager
    private let searchContext: NSManagedObjectContext
    
    // MARK: - Initialization
    init(credentials: APICredentialStore, authenticationService: AuthenticationService, userManager: UserManager, searchContext: NSManagedObjectContext) {
        self.credentials = credentials
        self.authenticationService = authenticationService
        self.userManager = userManager
        self.searchContext = searchContext
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
                    
                    self.userManager.findUserById(token.userID, context: self.searchContext) { user, error in
                        guard let user = user else {
                            // pass service / core data error
                            completion(nil, error)
                            return
                        }
                    
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
            let report = Report(ReportType.failedServerRequest(requestType: "LoginRequest", error: error), owner: nil)
            log.error(report)
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
                try self.credentials.reset()
                log.info("Successfully logged out user.")
                
                completion(nil)
            } catch {
                // pass keychain error
                log.error("Failed to remove credentials from keychain: \(error)")
                completion(error)
            }
        }
    }

    func getAuthenticatedUser(completion: @escaping (User?) -> Void) {
        // user is logged in if token exists and has userID associated
        let token = credentials.getToken()
        let userID = credentials.getUserID()
        
        if let token = token, let userID = userID {
            log.info("User '\(userID)' is already authenticated: \(token)")
            
            // get authenticated user
            userManager.findUserById(userID, context: searchContext) { user, error in
                guard let user = user else {
                    fatalError("Unable to retrieve currently authenticated user: \(error != nil ? error!.localizedDescription : "")")
                }
                
                completion(user)
            }
        } else {
            if token != nil || userID != nil {
                do {
                    try credentials.setToken(nil)
                    try credentials.setUserID(nil)
                    log.debug("Reset token or userID for partially authenticated user.")
                } catch {
                    log.error("Failed to reset token or userID for partially authenticated user: \(error)")
                }
            }
            
            completion(nil)
        }
    }
 
}
