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
import UIKit

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
                
                // update privacy
                let privacy = try Privacy.createOrUpdate(from: prototype.privacy, userID: Int(user.id), in: context)
                user.privacy = privacy
                
                // update current location if given
                if let location = prototype.location {
                    let location = try Location.create(from: location, in: context)
                    user.location = location
                }
                
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
        
        // set privacy
        let privacy = try Privacy.createOrUpdate(from: prototype.privacy, userID: Int(user.id), in: context)
        user.privacy = privacy

        // set current location if given
        if let location = prototype.location {
            let location = try Location.create(from: location, in: context)
            user.location = location
        }
        
        // retrieve public resources
        user.getProfile(completion: nil)
        user.getCars(completion: nil)
        user.getCommunityMessages(completion: nil)
        user.getTrafficMessages(completion: nil)
        user.getImage(completion: nil)
    
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
    
    var storedImage: UIImage? {
        guard let imageData = imageData else {
            return nil
        }
        
        return UIImage(data: imageData)
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
        getCars(completion: nil)
        getCommunityMessages(completion: nil)
        getTrafficMessages(completion: nil)
        getImage(completion: nil)
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
    
    func update(to user: UserRequest, completion: ((Error?) -> Void)?) {
        do {
            try userService.update(userID: Int(id), to: user) { error in
                guard error == nil else {
                    let report = Report(.failedServerOperation(.update, resource: nil, isMultiple: false, error: error!), owner: self)
                    log.error(report)
                    completion?(error!)
                    return
                }
                
                do {
                    self.email = user.email ?? self.email
                    self.username = user.username ?? self.username
                    try self.context.save()
                    
                    let report = Report(.successfulCoreDataOperation(.update, resource: nil, isMultiple: false), owner: self)
                    log.debug(report)
                    
                    completion?(nil)
                } catch {
                    // pass core data error
                    let report = Report(.failedCoreDataOperation(.update, resource: nil, isMultiple: false, error: error), owner: self)
                    log.error(report)
                    completion?(error)
                }
            }
        } catch {
            // pass body encoding error
            let report = Report(.failedServerRequest(requestType: "UserRequest", error: error), owner: self)
            log.error(report)
            completion?(error)
        }
    }
    
    func createCar(_ car: CarRequest, completion: ((Car?, Error?) -> Void)?) {
        do {
            try userService.createCar(car, userID: Int(id)) { car, error in
                guard let car = car else {
                    let report = Report(.failedServerOperation(.create, resource: "Car", isMultiple: false, error: error!), owner: self)
                    log.error(report)
                    completion?(nil, error!)
                    return
                }
    
                do {
                    let car = try Car.createOrUpdate(from: car, in: self.context)
                    self.addToCars(car)
                    try self.context.save()
    
                    let report = Report(.successfulCoreDataOperation(.create, resource: "Car", isMultiple: false), owner: self)
                    log.debug(report)
    
                    completion?(car, nil)
                } catch {
                    // pass core data error
                    let report = Report(.failedCoreDataOperation(.create, resource: "Car", isMultiple: false, error: error), owner: self)
                    log.error(report)
                    completion?(nil, error)
                }
            }
        } catch {
            // pass body encoding error
            let report = Report(.failedServerRequest(requestType: "CarRequest", error: error), owner: self)
            log.error(report)
            completion?(nil, error)
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
                    let coreProfile = try Profile.createOrUpdate(from: publicProfile, userID: Int(self.id), in: self.context)
                    self.profile = coreProfile
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
    
    func delete(completion: ((Error?) -> Void)?) {
        userService.delete(userID: Int(id)) { error in
            guard error == nil else {
                // pass service error
                let report = Report(.failedServerOperation(.delete, resource: nil, isMultiple: false, error: error!), owner: self)
                log.error(report)
                completion?(error!)
                return
            }
            
            do {
                self.context.delete(self)
                try self.context.save()
                let report = Report(.successfulCoreDataOperation(.delete, resource: nil, isMultiple: false), owner: self)
                log.debug(report)
                completion?(nil)
            } catch {
                let report = Report(.failedCoreDataOperation(.delete, resource: nil, isMultiple: false, error: error), owner: self)
                log.error(report)
                completion?(error)
            }
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
    
    func getSettings(completion: ((Error?) -> Void)?) {
        userService.getSettings(userID: Int(id)) { settings, error in
            guard let settings = settings else {
                // pass service error
                let report = Report(.failedServerOperation(.retrieve, resource: "Settings", isMultiple: false, error: error!), owner: self)
                log.error(report)
                completion?(error!)
                return
            }
            
            do {
                let settings = try Settings.createOrUpdate(from: settings, userID: Int(self.id), in: self.context)
                self.settings = settings
                try self.context.save()
                let report = Report(.successfulCoreDataOperation(.retrieve, resource: "Settings", isMultiple: false), owner: self)
                log.debug(report)
                completion?(nil)
            } catch {
                // pass core data error
                let report = Report(.failedCoreDataOperation(.retrieve, resource: "Settings", isMultiple: false, error: error), owner: self)
                log.error(report)
                completion?(error)
            }
        }
    }
    
    func getPrivacy(completion: ((Error?) -> Void)?) {
        userService.getPrivacy(userID: Int(id)) { privacy, error in
            guard let privacy = privacy else {
                // pass service error
                let report = Report(.failedServerOperation(.retrieve, resource: "Privacy", isMultiple: false, error: error!), owner: self)
                log.error(report)
                completion?(error!)
                return
            }
            
            do {
                let privacy = try Privacy.createOrUpdate(from: privacy, userID: Int(self.id), in: self.context)
                self.privacy = privacy
                try self.context.save()
                let report = Report(.successfulCoreDataOperation(.retrieve, resource: "Privacy", isMultiple: false), owner: self)
                log.debug(report)
                completion?(nil)
            } catch {
                // pass core data error
                let report = Report(.failedCoreDataOperation(.retrieve, resource: "Privacy", isMultiple: false, error: error), owner: self)
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
    
    func updateLocation(to location: LocationRequest, completion: ((Error?) -> Void)?) {
        do {
            try userService.updateLocation(userID: Int(id), to: location) { error in
                guard error == nil else {
                    // pass service error
                    let report = Report(.failedServerOperation(.update, resource: "Location", isMultiple: false, error: error!), owner: self)
                    log.error(report)
                    completion?(error!)
                    return
                }
                
                do {
                    let location = RoadChatKit.Location(locationRequest: location)
                    let coreLocation = try Location.create(from: RoadChatKit.Location.PublicLocation(location: location), in: self.context)
                    self.location = coreLocation
                    try self.context.save()
                    
                    let report = Report(.successfulCoreDataOperation(.update, resource: "Location", isMultiple: false), owner: self)
                    log.debug(report)
                    
                    completion?(nil)
                } catch {
                    // pass core data error
                    let report = Report(.failedCoreDataOperation(.update, resource: "Location", isMultiple: false, error: error), owner: self)
                    log.error(report)
                    completion?(error)
                }
            }
        } catch {
            // pass body encoding error
            let report = Report(.failedServerRequest(requestType: "LocationRequest", error: error), owner: self)
            log.error(report)
            completion?(error)
        }
    }
    
    func getTrafficMessages(completion: ((Error?) -> Void)?) {
        userService.getTrafficMessages(userID: Int(id)) { messages, error in
            guard let messages = messages else {
                // pass service error
                let report = Report(.failedServerOperation(.retrieve, resource: "TrafficMessage", isMultiple: true, error: error!), owner: self)
                log.error(report)
                completion?(error!)
                return
            }
            
            let coreMessages: [TrafficMessage] = messages.compactMap {
                do {
                    return try TrafficMessage.createOrUpdate(from: $0, in: self.context)
                } catch {
                    let report = Report(.failedCoreDataOperation(.create, resource: "TrafficMessage", isMultiple: false, error: error), owner: self)
                    log.error(report)
                    return nil
                }
            }
            
            self.addToTrafficMessages(NSSet(array: coreMessages))
            
            do {
                try self.context.save()
                let report = Report(.successfulCoreDataOperation(.retrieve, resource: "TrafficMessage", isMultiple: true), owner: self)
                log.debug(report)
                completion?(nil)
            } catch {
                let report = Report(.failedCoreDataOperation(.retrieve, resource: "TrafficMessage", isMultiple: true, error: error), owner: self)
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
    
    func createConversation(_ conversation: ConversationRequest, completion: @escaping (Conversation?, Error?) -> Void) {
        do {
            try conversationService.create(conversation) { conversation, error in
                guard let conversation = conversation else {
                    // pass service error
                    let report = Report(.failedServerOperation(.create, resource: "Conversation", isMultiple: false, error: error!), owner: self)
                    log.error(report)
                    completion(nil, error!)
                    return
                }
                
                do {
                    let conversation = try Conversation.createOrUpdate(from: conversation, in: self.context)
                    self.addToConversations(conversation)
                    try self.context.save()
                    
                    let report = Report(.successfulCoreDataOperation(.create, resource: "Conversation", isMultiple: false), owner: self)
                    log.debug(report)
                    
                    completion(conversation, nil)
                } catch {
                    // pass core data error
                    let report = Report(.failedCoreDataOperation(.create, resource: "Conversation", isMultiple: false, error: error), owner: self)
                    log.error(report)
                    completion(nil, error)
                }
            }
        } catch {
            // pass body encoding error
            let report = Report(.failedServerRequest(requestType: "ConversationRequest", error: error), owner: self)
            log.error(report)
            completion(nil, error)
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
                    let conversation = try Conversation.createOrUpdate(from: $0, in: self.context)
                    conversation.approvalStatus = conversation.getApprovalStatus(activeUser: self)?.rawValue
                    return conversation
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
    
    func getImage(completion: ((Error?) -> Void)?) {
        userService.getImage(userID: Int(id)) { image, error in
            guard let image = image else {
                let report = Report(.failedServerOperation(.retrieve, resource: "Image", isMultiple: false, error: error!), owner: self)
                log.error(report)
                completion?(error!)
                return
            }
            
            do {
                self.imageData = image.data
                try self.context.save()
                let report = Report(.successfulCoreDataOperation(.retrieve, resource: "Image", isMultiple: false), owner: self)
                log.debug(report)
                completion?(nil)
            } catch {
                let report = Report(.failedCoreDataOperation(.update, resource: "Image", isMultiple: false, error: error), owner: self)
                log.error(report)
                completion?(error)
            }
        }
    }
    
    func uploadImage(_ image: UIImage, completion: ((Error?) -> Void)?) {
        userService.uploadImage(image, userID: Int(id)) { data, error in
            guard let data = data else {
                let report = Report(.failedServerOperation(.update, resource: "Image", isMultiple: false, error: error!), owner: self)
                log.error(report)
                completion?(error!)
                return
            }
            
            do {
                self.imageData = data
                try self.context.save()
                let report = Report(.successfulCoreDataOperation(.update, resource: "Image", isMultiple: false), owner: self)
                log.debug(report)
                completion?(nil)
            } catch {
                let report = Report(.failedCoreDataOperation(.update, resource: "Image", isMultiple: false, error: error), owner: self)
                log.error(report)
                completion?(error)
            }
        }
    }
    
}
