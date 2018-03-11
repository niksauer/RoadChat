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
    
    let userService = UserService()
    
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
    
    class func create(from prototype: RoadChatKit.User.PublicUser, in context: NSManagedObjectContext) throws -> User {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "id = %d AND username = %@", prototype.id, prototype.username)
        
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
        user.id = Int32(prototype.id)
        user.email = prototype.email
        user.username = prototype.username
        user.registry = prototype.registry
        
        return user
    }

    func getProfile(completion: @escaping (Error?) -> Void) {
        userService.getProfile(userID: Int(id)) { profile, error in
            guard let profile = profile else {
                log.error("Failed to get profile for user '\(self.id)': \(error!)")
                completion(error!)
                return
            }
            
            do {
                let profile = try Profile.createOrUpdate(from: profile, userID: Int(self.id), in: CoreDataStack.shared.viewContext)
                self.profile = profile
                CoreDataStack.shared.saveViewContext()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    func getConversations(completion: @escaping (Error?) -> Void) {
        userService.getConversations(userID: Int(id)) { conversations, error in
            guard let conversations = conversations else {
                // pass service error
                log.error("Failed to get conversations for user '\(self.id)': \(error!)")
                completion(error!)
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
                            completion(nil)
                        }
                    } catch {
                        log.error("Failed to save Core Data 'Conversation' instances: \(error)")
                        
                        OperationQueue.main.addOperation {
                            completion(error)
                        }
                    }
                } else {
                    OperationQueue.main.addOperation {
                        completion(nil)
                    }
                }
            }
        }
    }
    
}
