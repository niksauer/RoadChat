//
//  Conversation.swift
//  RoadChat
//
//  Created by Niklas Sauer on 02.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import CoreData
import RoadChatKit

enum ConversationError: Error {
    case notParticipating
}

class Conversation: NSManagedObject, ReportOwner {
    
    // MARK: - Public Class Methods
    class func createOrUpdate(from response: RoadChatKit.Conversation.PublicConversation, in context: NSManagedObjectContext) throws -> Conversation {
        let request: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        request.predicate = NSPredicate(format: "id = %d", response.id)
        
        do {
            let matches = try context.fetch(request)
            
            if matches.count > 0 {
                assert(matches.count >= 1, "Conversation.create -- Database Inconsistency")
                
                // update existing conversation
                let conversation = matches.first!
                conversation.title = response.title
                conversation.lastChange = response.newestMessage?.time ?? response.creation
                
                return conversation
            }
        } catch {
            throw error
        }
        
        // create new conversation
        let conversation = Conversation(context: context)
        conversation.id = Int32(response.id)
        conversation.creatorID = Int32(response.creatorID)
        conversation.title = response.title
        conversation.creation = response.creation
        conversation.lastChange = response.newestMessage?.time ?? response.creation
        
        // retrieve resources
        conversation.getMessages(completion: nil)
        conversation.getParticipants(completion: nil)
        
        return conversation
    }
    
    // MARK: - Public Properties
    var storedParticipants: [Participant] {
        return Array(participants!) as! [Participant]
    }
    
    var newestMessage: DirectMessage? {
        return (Array(messages!) as! [DirectMessage]).sorted(by: { $0.time! > $1.time! }).first
    }
    
    // MARK: - ReportOwner Protocol
    var logDescription: String {
        return "'Conversation' [id: '\(self.id)']"
    }
    
    // MARK: - Private Properties
    private let conversationService = ConversationService(credentials: CredentialManager.shared)
    private let context: NSManagedObjectContext = CoreDataStack.shared.viewContext

    // MARK: - Public Methods
    func get(completion: ((Error?) -> Void)?) {
        conversationService.get(conversationID: Int(id)) { conversation, error in
            guard let conversation = conversation else {
                // pass service error
                let report = Report(.failedServerOperation(.retrieve, resource: nil, isMultiple: false, error: error!), owner: self)
                log.error(report)
                completion?(error!)
                return
            }
            
            do {
                _ = try Conversation.createOrUpdate(from: conversation, in: self.context)
                try self.context.save()
                let report = Report(.successfulCoreDataOperation(.retrieve, resource: nil, isMultiple: false), owner: self)
                log.debug(report)
                completion?(nil)
            } catch {
                let report = Report(.failedCoreDataOperation(.retrieve, resource: nil, isMultiple: false, error: error), owner: self)
                log.error(report)
                completion?(error)
            }
        }
    }
    
    func delete(completion: @escaping (Error?) -> Void) {
        conversationService.delete(conversationID: Int(id)) { error in
            guard error == nil else {
                // pass service error
                let report = Report(.failedServerOperation(.delete, resource: nil, isMultiple: false, error: error!), owner: self)
                log.error(report)
                completion(error!)
                return
            }

            do {
                self.context.delete(self)
                try self.context.save()
                let report = Report(.successfulCoreDataOperation(.delete, resource: nil, isMultiple: false), owner: self)
                log.debug(report)
                completion(nil)
            } catch {
                let report = Report(.failedCoreDataOperation(.delete, resource: nil, isMultiple: false, error: error), owner: self)
                log.error(report)
                completion(error)
            }
        }
    }
 
    func getMessages(completion: ((Error?) -> Void)?) {
        conversationService.getMessages(conversationID: Int(id)) { messages, error in
            guard let messages = messages else {
                // pass service error
                let report = Report(.failedServerOperation(.retrieve, resource: "DirectMessage", isMultiple: true, error: error!), owner: self)
                log.error(report)
                completion?(error!)
                return
            }
            
            let coreMessages: [DirectMessage] = messages.compactMap {
                do {
                    return try DirectMessage.create(from: $0, conversationID: Int(self.id), in: self.context)
                } catch {
                    let report = Report(.failedCoreDataOperation(.create, resource: "DirectMessage", isMultiple: true, error: error), owner: self)
                    log.error(report)
                    return nil
                }
            }
            
            self.addToMessages(NSSet(array: coreMessages))

            do {
                try self.context.save()
                let report = Report(.successfulCoreDataOperation(.retrieve, resource: "DirectMessage", isMultiple: true), owner: self)
                log.debug(report)
                completion?(nil)
            } catch {
                let report = Report(.failedCoreDataOperation(.retrieve, resource: "DirectMessage", isMultiple: true, error: error), owner: self)
                log.error(report)
                completion?(error)
            }
        }
    }

    func createMessage(_ message: DirectMessageRequest, completion: @escaping (Error?) -> Void) {
        do {
            try conversationService.createMessage(message, conversationID: Int(id)) { message, error in
                guard let message = message else {
                    // pass service error
                    let report = Report(.failedServerOperation(.create, resource: "DirectMessage", isMultiple: false, error: error!), owner: self)
                    log.error(report)
                    completion(error!)
                    return
                }
                
                do {
                    _ = try DirectMessage.create(from: message, conversationID: Int(self.id), in: self.context)
                    try self.context.save()
                    let report = Report(.successfulCoreDataOperation(.create, resource: "DirectMessage", isMultiple: false), owner: self)
                    log.debug(report)
                    completion(nil)
                } catch {
                    // pass core data error
                    let report = Report(.failedCoreDataOperation(.create, resource: "DirectMessage", isMultiple: false, error: error), owner: self)
                    log.error(report)
                    completion(error)
                }
            }
        } catch {
            // pass body encoding error
            let report = Report(.failedServerRequest(requestType: "DirectMessageRequest", error: error), owner: self)
            log.error(report)
            completion(error)
        }
    }
    
    func getParticipants(completion: ((Error?) -> Void)?) {
        conversationService.getParticipants(conversationID: Int(id)) { participants, error in
            guard let participants = participants else {
                // pass service error
                let report = Report(.failedServerOperation(.retrieve, resource: "Participant", isMultiple: true, error: error!), owner: self)
                log.error(report)
                completion?(error!)
                return
            }
            
            let coreParticipants: [Participant] = participants.compactMap {
                do {
                    return try Participant.createOrUpdate(from: $0, conversationID: Int(self.id), in: self.context)
                } catch {
                    let report = Report(.failedCoreDataOperation(.create, resource: "Participant", isMultiple: false, error: error), owner: self)
                    log.error(report)
                    return nil
                }
            }
            
            self.addToParticipants(NSSet(array: coreParticipants))
            
            do {
                try self.context.save()
                let report = Report(.successfulCoreDataOperation(.retrieve, resource: "Participant", isMultiple: true), owner: self)
                log.debug(report)
                completion?(nil)
            } catch {
                let report = Report(.failedCoreDataOperation(.retrieve, resource: "Participant", isMultiple: true, error: error), owner: self)
                log.error(report)
                completion?(error)
            }
        }
    }
    
    func accept(completion: @escaping (Error?) -> Void) {
        conversationService.accept(conversationID: Int(id)) { error in
            guard error == nil else {
                // pass service error
                let report = Report(.failedServerOperation(.update, resource: "ApprovalStatus", isMultiple: false, error: error!), owner: self)
                log.error(report)
                completion(error!)
                return
            }
            
            self.setApprovalStatus(.denied, completion: completion)
        }
    }
    
    func deny(completion: @escaping (Error?) -> Void) {
        conversationService.delete(conversationID: Int(id)) { error in
            guard error == nil else {
                // pass service error
                let report = Report(.failedServerOperation(.update, resource: "ApprovalStatus", isMultiple: false, error: error!), owner: self)
                log.error(report)
                completion(error!)
                return
            }
            
            self.setApprovalStatus(.denied, completion: completion)
        }
    }
    
    // MARK: - Private Methods
    private func setApprovalStatus(_ status: ApprovalType, completion: (Error?) -> Void) {
        guard let participation = self.storedParticipants.first(where: { $0.userID == self.user?.id }) else {
            // pass model validation error
            log.error("\(self.user!.logDescription) is not participating in \(self.logDescription)")
            completion(ConversationError.notParticipating)
            return
        }
        
        do {
            participation.setApprovalStatus(status)
            try self.context.save()
            let report = Report(ReportType.successfulCoreDataOperation(.update, resource: "ApprovalStatus", isMultiple: false), owner: self)
            log.debug(report)
            completion(nil)
        } catch {
            let report = Report(ReportType.failedCoreDataOperation(.update, resource: "ApprovalStatus", isMultiple: false, error: error), owner: self)
            log.error(report)
            completion(error)
        }
    }

}
