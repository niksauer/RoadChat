//
//  UserManager.swift
//  RoadChat
//
//  Created by Niklas Sauer on 19.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import CoreData
import RoadChatKit

struct UserManager {
    
    // MARK: - Private Properties
    private let userService: UserService
    
    // MARK: - Initialization
    init(userService: UserService) {
        self.userService = userService
    }
    
    // MARK: - Public Methods
    func createUser(_ user: RegisterRequest, completion: @escaping (Error?) -> Void) {
        do {
            try userService.create(user) { user, error in
                guard let user = user else {
                    // pass service error
                    log.error("Failed to register user: \(error!)")
                    completion(error!)
                    return
                }
                
                do {
                    _ = try User.createOrUpdate(from: user, in: CoreDataStack.shared.viewContext)
                    CoreDataStack.shared.saveViewContext()
                    log.info("Successfully registered user.")
                    completion(nil)
                } catch {
                    // pass core data error
                    log.error("Failed to create Core Data 'User' instance: \(error)")
                    completion(error)
                }
            }
        } catch {
            // pass body encoding error
            log.error("Failed to send 'RegisterRequest': \(error)")
            completion(error)
        }
    }
    
    func findUserById(_ id: Int) -> User? {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "id = %d", id)
        
        let matches = try? CoreDataStack.shared.viewContext.fetch(request)
        return matches?.first
    }
    
    func getUserById(_ id: Int, completion: @escaping (User?, Error?) -> Void) {
        userService.get(userID: id) { user, error in
            guard let user = user else {
                // pass service error
                log.error("Failed to retrieve user: \(error!)")
                completion(nil, error!)
                return
            }
            
            do {
                let user = try User.createOrUpdate(from: user, in: CoreDataStack.shared.viewContext)
                CoreDataStack.shared.saveViewContext()
                log.debug("Successfully retrieved user '\(user.id)'.")
                completion(user, nil)
            } catch {
                // pass core data error
                log.error("Failed to create Core Data 'User' instance: \(error)")
                completion(nil, error)
            }
        }
    }
    
}
