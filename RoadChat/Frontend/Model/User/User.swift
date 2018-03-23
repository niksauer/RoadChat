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
    
    // MARK: - Public Class Methods
    class func createOrUpdate(from response: RoadChatKit.User.PublicUser, in context: NSManagedObjectContext) throws -> User {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "id = %d", response.id)
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count >= 1, "User.create -- Database Inconsistency")
                
                // update existing user
                let user = matches.first!
                user.email = response.email
                user.username = response.username
                
                return user
            }
        } catch {
            throw error
        }
        
        // create new user
        let user = User(context: context)
        user.id = Int32(response.id)
        user.email = response.email
        user.username = response.username
        user.registry = response.registry
        
        // retrieve resources
        user.getProfile(completion: nil)
        user.getConversations(completion: nil)
        
        return user
    }
    
    // MARK: - Public Properties
    var storedConversations: [Conversation] {
        return Array(conversations!) as! [Conversation]
    }
    
    // MARK: - Private Properties
    private let userService = UserService(credentials: CredentialManager.shared)
    private let conversationService = ConversationService(credentials: CredentialManager.shared)
    private let context = CoreDataStack.shared.viewContext
    
    // MARK: - Initialization
    override func awakeFromFetch() {
        super.awakeFromFetch()
        get(completion: nil)
        getProfile(completion: nil)
        getConversations(completion: nil)
    }
    
    // MARK: - Public Methods
    func get(completion: ((Error?) -> Void)?) {
        userService.get(userID: Int(id)) { user, error in
            guard let user = user else {
                // pass service error
                log.error("Failed to update user '\(self.id)': \(error!)")
                completion?(error!)
                return
            }
            
            do {
                _ = try User.createOrUpdate(from: user, in: self.context)
                try self.context.save()
                log.debug("Successfully saved created or updated Core Data 'User' instance.")
                completion?(nil)
            } catch {
                log.error("Failed to save updated Core Data 'User' instance: \(error)")
                completion?(error)
            }
        }
    }
    
    func createOrUpdateProfile(_ profile: ProfileRequest, completion: @escaping (Error?) -> Void) {
        do {
            try userService.createOrUpdateProfile(userID: Int(id), to: profile) { error in
                guard error == nil else {
                    // pass service error
                    log.error("Failed to update profile for user '\(self.id)': \(error!)")
                    completion(error!)
                    return
                }
                
                do {
                    let privacy = RoadChatKit.Privacy(userID: Int(self.id))
                    let profile = RoadChatKit.Profile(userID: Int(self.id), profileRequest: profile)
                    let publicProfile = RoadChatKit.Profile.PublicProfile(profile: profile, privacy: privacy, isOwner: true)
                    let _ = try Profile.createOrUpdate(from: publicProfile, userID: Int(self.id), in: self.context)
                    try self.context.save()
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
                let profile = try Profile.createOrUpdate(from: profile, userID: Int(self.id), in: self.context)
                self.profile = profile
                try self.context.save()
                log.info("Successfully saved created or updated Core Data 'Profile' instance.")
                completion?(nil)
            } catch {
                // pass core data error
                log.error("Failed to create Core Data 'Profile' instance: \(error)")
                completion?(error)
            }
        }
    }
    
    func createConversation(_ conversation: ConversationRequest, completion: @escaping (Error?) -> Void) {
        do {
            try conversationService.create(conversation) { conversation, error in
                guard let conversation = conversation else {
                    // pass service error
                    log.error("Failed to create conversation: \(error!)")
                    completion(error!)
                    return
                }
                
                do {
                    let conversation = try Conversation.createOrUpdate(from: conversation, in: self.context)
                    self.addToConversations(conversation)
                    try self.context.save()
                    log.info("Successfully created Core Data 'Conversation' instance.")
                    completion(nil)
                } catch {
                    // pass core data error
                    log.error("Failed to create Core Data 'Conversation' instance: \(error)")
                    completion(error)
                }
            }
        } catch {
            // pass body encoding error
            log.error("Failed to send 'ConversationRequest': \(error)")
            completion(error)
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
            
            _ = conversations.map {
                do {
                    let conversation = try Conversation.createOrUpdate(from: $0, in: self.context)
                    self.addToConversations(conversation)
                } catch {
                    log.error("Failed to create Core Data 'Conversation' instance: \(error)")
                }
            }

            do {
                try self.context.save()
                log.info("Successfully saved created Core Data 'Conversation' instances.")
                completion?(nil)
            } catch {
                log.error("Failed to save Core Data 'Conversation' instances: \(error)")
                completion?(error)
            }
        }
    }
    
}
