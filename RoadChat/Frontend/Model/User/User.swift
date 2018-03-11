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

enum UserError: Error {
    case duplicate
}

class User: NSManagedObject {
    
    // MARK: - Public Static Methods
    static func create(_ user: RegisterRequest, completion: @escaping (Error?) -> Void) {
        do {
            try UserService().create(user) { user, error in
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
    
    // MARK: - Public Class Methods
    class func create(from response: RoadChatKit.User.PublicUser, in context: NSManagedObjectContext) throws -> User {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "id = %d AND username = %@", response.id, response.username)
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count >= 1, "User.create -- Database Inconsistency")
                throw UserError.duplicate
            }
        } catch {
            throw error
        }
        
        let user = User(context: context)
        user.id = Int32(response.id)
        user.email = response.email
        user.username = response.username
        user.registry = response.registry
        
        return user
    }

    // MARK: - Public Properties
    let userService = UserService()
    
    // MARK: - Initialization
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        
        getProfile(completion: nil)
        getConversations(completion: nil)
    }
    
    // MARK: - Public Methods
    func createOrUpdateProfile(from request: ProfileRequest, completion: @escaping (Error?) -> Void) {
        do {
            try userService.createOrUpdateProfile(userID: Int(id), to: request) { error in
                guard error == nil else {
                    // pass service error
                    log.error("Failed to update profile for user '\(self.id)': \(error!)")
                    completion(error!)
                    return
                }
                
                do {
                    let profile = try Profile.createOrUpdate(from: request, user: self, in: CoreDataStack.shared.viewContext)
                    self.profile = profile
                    CoreDataStack.shared.saveViewContext()
                    log.info("Successfully saved created or updated Core Data 'Profile' instance.")
                    completion(nil)
                } catch {
                    // pass core data error
                    log.error("Failed to create Core Data 'Profile' instance: \(error)")
                    completion(error)
                }
            }
        } catch {
            // pass body encoding error
            log.error("Failed to send 'ProfileRequest': \(error)")
            completion(error)
        }
    }
    
    func getProfile(completion: ((Error?) -> Void)?) {
        userService.getProfile(userID: Int(id)) { profile, error in
            guard let profile = profile else {
                // pass service error
                log.error("Failed to get profile for user '\(self.id)': \(error!)")
                completion?(error!)
                return
            }
            
            do {
                let profile = try Profile.createOrUpdate(from: profile, user: self, in: CoreDataStack.shared.viewContext)
                self.profile = profile
                CoreDataStack.shared.saveViewContext()
                log.info("Successfully saved created or updated Core Data 'Profile' instance.")
                completion?(nil)
            } catch {
                // pass core data error
                log.error("Failed to create Core Data 'Profile' instance: \(error)")
                completion?(error)
            }
        }
    }
    
    func getConversations(completion: ((Error?) -> Void)?) {
        userService.getConversations(userID: Int(id)) { conversations, error in
            guard let conversations = conversations else {
                // pass service error
                log.error("Failed to get conversations for user '\(self.id)': \(error!)")
                completion?(error!)
                return
            }
            
            CoreDataStack.shared.persistentContainer.performBackgroundTask {  context in
                _ = conversations.map {
                    do {
                        _ = try Conversation.createOrUpdate(from: $0, in: context)
                    } catch {
                        log.error("Failed to create Core Data 'Conversation' instance: \(error)")
                    }
                }
                
//                _ = conversations.map { _ = try? Conversation.create(from: $0, in: context) }
                
                if context.hasChanges {
                    do {
                        try context.save()
                        log.info("Successfully saved created Core Data 'Conversation' instances.")
                        
                        OperationQueue.main.addOperation {
                            completion?(nil)
                        }
                    } catch {
                        log.error("Failed to save Core Data 'Conversation' instances: \(error)")
                        
                        OperationQueue.main.addOperation {
                            completion?(error)
                        }
                    }
                } else {
                    OperationQueue.main.addOperation {
                        completion?(nil)
                    }
                }
            }
        }
    }
    
}
