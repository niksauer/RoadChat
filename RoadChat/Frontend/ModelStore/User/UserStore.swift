//
//  UserStore.swift
//  RoadChat
//
//  Created by Niklas Sauer on 09.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import RoadChatKit

struct UserStore {
    
    private let userService = UserService()
    
    func create(_ user: RegisterRequest, completion: @escaping (Error?) -> Void) {
        do {
            try userService.create(user) { user, error in
                guard let user = user else {
                    // pass service error
                    log.error("Failed to register user: \(error!)")
                    completion(error!)
                    return
                }
                
                do {
                    try CredentialManager.shared.setUserID(user.id)
                } catch {
                    // pass keychain error
                    log.error("Failed to save credentials to keychain: \(error)")
                    completion(error)
                }
                
                do {
                    _ = try User.create(from: user, in: CoreDataStack.shared.viewContext)
                    CoreDataStack.shared.saveViewContext()
                } catch {
                    // pass core data error
                    log.error("Failed to create Core Data 'User' entity: \(error)")
                    completion(error)
                }
                
                log.info("Successfully registered user.")
                completion(nil)
            }
        } catch {
            // pass body encoding error
            log.error("Failed to send 'RegisterRequest': \(error)")
            completion(error)
        }
    }
    
}
