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

class User: NSManagedObject, ReportOwner {
    
    // MARK: - Public Class Methods
    class func createOrUpdate(from prototype: RoadChatKit.User.PublicUser, in context: NSManagedObjectContext) throws -> User {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "id = %d", prototype.id)
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count >= 1, "User.create -- Database Inconsistency")
                
                // update existing user
                let user = matches.first!
                user.email = prototype.email
                user.username = prototype.username
                
                return user
            }
        } catch {
            throw error
        }
        
        // create new user
        let user = User(context: context)
        user.id = Int32(prototype.id)
        user.email = prototype.email
        user.username = prototype.username
        user.registry = prototype.registry
        
        // retrieve resources
        user.getProfile(completion: nil)
        user.getConversations(completion: nil)
    
        // set location
        if let location = prototype.location {
            let location = try Location.create(from: location, in: context)
            user.location = location
        }
    
        return user
    }
    
    // MARK: - Public Properties
    var storedConversations: [Conversation] {
        return Array(conversations!) as! [Conversation]
    }
    
    var storedCommunityMessages: [CommunityMessage] {
        return Array(communityMessages!) as! [CommunityMessage]
    }
    
    var storedTrafficMessages: [TrafficMessage] {
        return Array(trafficMessages!) as! [TrafficMessage]
    }
    
    var storedCars: [Car] {
        return Array(cars!) as! [Car]
    }
    
    var communityKarma: Int {
        return Int(storedCommunityMessages.reduce(0, { $0 + $1.upvotes }))
    }
    
    var trafficKarma: Int {
        return Int(storedTrafficMessages.reduce(0, { $0 + $1.upvotes }))
    }
    
    // MARK: - Private Properties
    private let userService = UserService(config: DependencyContainer().config)
    private let conversationService = ConversationService(config: DependencyContainer().config)
    private let context = CoreDataStack.shared.viewContext
    
    // MARK: - ReportOwner Protocol
    var logDescription: String {
        return "'User' [id: '\(self.id)']"
    }
    
    // MARK: - Initialization
    override func awakeFromFetch() {
        super.awakeFromFetch()
        get(completion: nil)
        getProfile(completion: nil)
        getConversations(completion: nil)
        getCommunityMessages(completion: nil)
    }
    
    // MARK: - Public Methods
    func get(completion: ((Error?) -> Void)?) {
        userService.get(userID: Int(id)) { user, error in
            guard let user = user else {
                // pass service error
                let report = Report(.failedServerOperation(.retrieve, resource: nil, isMultiple: false, error: error!), owner: self)
                log.error(report)
                completion?(error!)
                return
            }
            
            do {
                _ = try User.createOrUpdate(from: user, in: self.context)
                try self.context.save()
                let report = Report(.successfulCoreDataOperation(.retrieve, resource: nil, isMultiple: false), owner: self)
                log.debug(report)
                completion?(nil)
            } catch {
                let report = Report(.failedCoreDataOperation(.create, resource: nil, isMultiple: false, error: error), owner: self)
                log.error(report)
                completion?(error)
            }
        }
    }
    
    func createOrUpdateProfile(_ profile: ProfileRequest, completion: @escaping (Error?) -> Void) {
        do {
            try userService.createOrUpdateProfile(userID: Int(id), to: profile) { error in
                guard error == nil else {
                    // pass service error
                    let report = Report(.failedServerOperation(.update, resource: "Profile", isMultiple: false, error: error!), owner: self)
                    log.error(report)
                    completion(error!)
                    return
                }
                
                do {
                    let privacy = RoadChatKit.Privacy(userID: Int(self.id))
                    let profile = try RoadChatKit.Profile(userID: Int(self.id), profileRequest: profile)
                    let publicProfile = RoadChatKit.Profile.PublicProfile(profile: profile, privacy: privacy, isOwner: true)
                    let _ = try Profile.createOrUpdate(from: publicProfile, userID: Int(self.id), in: self.context)
                    try self.context.save()

                    let report = Report(.successfulCoreDataOperation(.update, resource: "Profile", isMultiple: false), owner: self)
                    log.debug(report)
                    
                    completion(nil)
                } catch {
                    // pass core data error
                    let report = Report(.failedCoreDataOperation(.update, resource: "Profile", isMultiple: false, error: error), owner: self)
                    log.error(report)
                    completion(error)
                }
            }
        } catch {
            // pass body encoding error
            let report = Report(.failedServerRequest(requestType: "ProfileRequest", error: error), owner: self)
            log.error(report)
            completion(error)
        }
    }
    
    func getProfile(completion: ((Error?) -> Void)?) {
        userService.getProfile(userID: Int(id)) { profile, error in
            guard let profile = profile else {
                // pass service error
                let report = Report(.failedServerOperation(.retrieve, resource: "Profile", isMultiple: false, error: error!), owner: self)
                log.error(report)
                completion?(error!)
                return
            }
            
            do {
                let profile = try Profile.createOrUpdate(from: profile, userID: Int(self.id), in: self.context)
                self.profile = profile
                try self.context.save()
                let report = Report(.successfulCoreDataOperation(.retrieve, resource: "Profile", isMultiple: false), owner: self)
                log.debug(report)
                completion?(nil)
            } catch {
                // pass core data error
                let report = Report(.failedCoreDataOperation(.retrieve, resource: "Profile", isMultiple: false, error: error), owner: self)
                log.error(report)
                completion?(error)
            }
        }
    }
    
    func getCars(completion: ((Error?) -> Void)?) {
        userService.getCars(userID: Int(id)) { cars, error in
            guard let cars = cars else {
                // pass service error
                let report = Report(.failedServerOperation(.retrieve, resource: "Car", isMultiple: true, error: error!), owner: self)
                log.error(report)
                completion?(error!)
                return
            }
            
            let coreCars: [Car] = cars.compactMap {
                do {
                    return try Car.createOrUpdate(from: $0, in: self.context)
                } catch {
                    let report = Report(.failedCoreDataOperation(.create, resource: "Car", isMultiple: false, error: error), owner: self)
                    log.error(report)
                    return nil
                }
            }
            
            self.addToCars(NSSet(array: coreCars))
            
            do {
                try self.context.save()
                let report = Report(.successfulCoreDataOperation(.retrieve, resource: "Car", isMultiple: true), owner: self)
                log.debug(report)
                completion?(nil)
            } catch {
                let report = Report(.failedCoreDataOperation(.retrieve, resource: "Car", isMultiple: true, error: error), owner: self)
                log.error(report)
                completion?(error)
            }
        }
    }
    
    func createConversation(_ conversation: ConversationRequest, completion: @escaping (Error?) -> Void) {
        do {
            try conversationService.create(conversation) { conversation, error in
                guard let conversation = conversation else {
                    // pass service error
                    let report = Report(.failedServerOperation(.create, resource: "Conversation", isMultiple: false, error: error!), owner: self)
                    log.error(report)
                    completion(error!)
                    return
                }
                
                do {
                    let conversation = try Conversation.createOrUpdate(from: conversation, in: self.context)
                    self.addToConversations(conversation)
                    try self.context.save()
                    
                    let report = Report(.successfulCoreDataOperation(.create, resource: "Conversation", isMultiple: false), owner: self)
                    log.debug(report)
                    
                    completion(nil)
                } catch {
                    // pass core data error
                    let report = Report(.failedCoreDataOperation(.create, resource: "Conversation", isMultiple: false, error: error), owner: self)
                    log.error(report)
                    completion(error)
                }
            }
        } catch {
            // pass body encoding error
            let report = Report(.failedServerRequest(requestType: "ConversationRequest", error: error), owner: self)
            log.error(report)
            completion(error)
        }
    }
    
    func getConversations(completion: ((Error?) -> Void)?) {
        userService.getConversations(userID: Int(id)) { conversations, error in
            guard let conversations = conversations else {
                // pass service error
                let report = Report(.failedServerOperation(.retrieve, resource: "Conversation", isMultiple: true, error: error!), owner: self)
                log.error(report)
                completion?(error!)
                return
            }
            
            let coreConversations: [Conversation] = conversations.compactMap {
                do {
                    return try Conversation.createOrUpdate(from: $0, in: self.context)
                } catch {
                    let report = Report(.failedCoreDataOperation(.create, resource: "Conversation", isMultiple: false, error: error), owner: self)
                    log.error(report)
                    return nil
                }
            }
        
            self.addToConversations(NSSet(array: coreConversations))
            
            do {
                try self.context.save()
                let report = Report(.successfulCoreDataOperation(.retrieve, resource: "Conversation", isMultiple: true), owner: self)
                log.debug(report)
                completion?(nil)
            } catch {
                let report = Report(.failedCoreDataOperation(.retrieve, resource: "Conversation", isMultiple: true, error: error), owner: self)
                log.error(report)
                completion?(error)
            }
        }
    }
 
    func getCommunityMessages(completion: ((Error?) -> Void)?) {
        userService.getCommunityMessages(userID: Int(id)) { messages, error in
            guard let messages = messages else {
                // pass service error
                let report = Report(.failedServerOperation(.retrieve, resource: "CommunityMessage", isMultiple: true, error: error!), owner: self)
                log.error(report)
                completion?(error!)
                return
            }
            
            let coreMessages: [CommunityMessage] = messages.compactMap {
                do {
                    return try CommunityMessage.createOrUpdate(from: $0, in: self.context)
                } catch {
                    let report = Report(.failedCoreDataOperation(.create, resource: "CommunityMessage", isMultiple: false, error: error), owner: self)
                    log.error(report)
                    return nil
                }
            }
            
            self.addToCommunityMessages(NSSet(array: coreMessages))
            
            do {
                try self.context.save()
                let report = Report(.successfulCoreDataOperation(.retrieve, resource: "CommunityMessage", isMultiple: true), owner: self)
                log.debug(report)
                completion?(nil)
            } catch {
                let report = Report(.failedCoreDataOperation(.retrieve, resource: "CommunityMessage", isMultiple: true, error: error), owner: self)
                log.error(report)
                completion?(error)
            }
        }
    }
}
