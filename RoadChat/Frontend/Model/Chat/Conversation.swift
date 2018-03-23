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

class Conversation: NSManagedObject {
    
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
    
    // MARK: - Private Properties
    private let conversationService = ConversationService(credentials: CredentialManager.shared)
    private let context: NSManagedObjectContext = CoreDataStack.shared.viewContext
    
    // MARK: - Public Methods
    func get(completion: ((Error?) -> Void)?) {
        conversationService.get(conversationID: Int(id)) { conversation, error in
            guard let conversation = conversation else {
                // pass service error
                log.error("Failed to update conversation '\(self.id)': \(error!)")
                completion?(error!)
                return
            }
            
            do {
                _ = try Conversation.createOrUpdate(from: conversation, in: self.context)
                try self.context.save()
                log.info("Successfully saved updated Core Data 'Conversation' instance.")
                completion?(nil)
            } catch {
                log.error("Failed to save updated Core Data 'Conversation' instance: \(error)")
                completion?(error)
            }
        }
    }
    
    func delete(completion: @escaping (Error?) -> Void) {
        conversationService.delete(conversationID: Int(id)) { error in
            guard error == nil else {
                // pass service error
                log.error("Failed to delete conversation '\(self.id)': \(error!)")
                completion(error!)
                return
            }

            do {
                self.context.delete(self)
                try self.context.save()
                log.info("Successfully deleted Core Data 'Conversation' instance.")
                completion(nil)
            } catch {
                log.error("Failed to delete Core Data 'Conversation' instance: \(error)")
                completion(error)
            }
        }
    }
 
    func getMessages(completion: ((Error?) -> Void)?) {
        conversationService.getMessages(conversationID: Int(id)) { messages, error in
            guard let messages = messages else {
                // pass service error
                log.error("Failed to get messages for conversation '\(self.id)': \(error!)")
                completion?(error!)
                return
            }
            
            _ = messages.map {
                do {
                    let message = try DirectMessage.create(from: $0, conversationID: Int(self.id), in: self.context)
                    self.addToMessages(message)
                } catch {
                    log.error("Failed to create Core Data 'DirectMessage' instance: \(error)")
                }
            }

            do {
                try self.context.save()
                log.info("Successfully saved created Core Data 'DirectMessage' instances.")
                completion?(nil)
            } catch {
                log.error("Failed to save Core Data 'DirectMessage' instances: \(error)")
                completion?(error)
            }
        }
    }

    func createMessage(_ message: DirectMessageRequest, completion: @escaping (Error?) -> Void) {
        do {
            try conversationService.createMessage(message, conversationID: Int(id)) { message, error in
                guard let message = message else {
                    // pass service error
                    log.error("Failed to create message for conversation '\(self.id)': \(error!)")
                    completion(error!)
                    return
                }
                
                do {
                    _ = try DirectMessage.create(from: message, conversationID: Int(self.id), in: self.context)
                    try self.context.save()
                    log.info("Successfully created Core Data 'DirectMessage' instance.")
                    completion(nil)
                } catch {
                    // pass core data error
                    log.error("Failed to create Core Data 'DirectMessage' instance: \(error)")
                    completion(error)
                }
            }
        } catch {
            // pass body encoding error
            log.error("Failed to send 'DirectMessageRequest': \(error)")
            completion(error)
        }
    }
    
    func getParticipants(completion: ((Error?) -> Void)?) {
        conversationService.getParticipants(conversationID: Int(id)) { participants, error in
            guard let participants = participants else {
                // pass service error
                log.error("Failed to get participants for conversation '\(self.id)': \(error!)")
                completion?(error!)
                return
            }
            
            _ = participants.map {
                do {
                    let participant = try Participant.createOrUpdate(from: $0, conversationID: Int(self.id), in: self.context)
                    self.addToParticipants(participant)
                } catch {
                    log.error("Failed to create Core Data 'Participant' instance: \(error)")
                }
            }
            
            do {
                try self.context.save()
                completion?(nil)
                log.info("Successfully saved created Core Data 'Participant' instances.")
            } catch {
                log.error("Failed to save Core Data 'Participant' instances: \(error)")
                completion?(error)
            }
        }
    }
    
    func accept(completion: @escaping (Error?) -> Void) {
        conversationService.accept(conversationID: Int(id)) { error in
            guard error == nil else {
                // pass service error
                log.error("Failed to accept conversation '\(self.id)': \(error!)")
                completion(error!)
                return
            }
            
            guard let participation = self.storedParticipants.first(where: { $0.userID == self.user?.id }) else {
                // pass model validation error
                completion(ConversationError.notParticipating)
                return
            }
            
            do {
                participation.setApprovalStatus(.accepted)
                try self.context.save()
                log.info("Successfully updated approval status for Core Data 'Conversation' instance.")
                completion(nil)
            } catch {
                log.error("Failed to update approval status for Core Data 'Conversaton' instance: \(error)")
                completion(error)
            }
        }
    }
    
    func deny(completion: @escaping (Error?) -> Void) {
        conversationService.delete(conversationID: Int(id)) { error in
            guard error == nil else {
                // pass service error
                log.error("Failed to deny conversation '\(self.id)': \(error!)")
                completion(error!)
                return
            }
            
            guard let participation = self.storedParticipants.first(where: { $0.userID == self.user?.id }) else {
                // pass model validation error
                completion(ConversationError.notParticipating)
                return
            }
            
            do {
                participation.setApprovalStatus(.denied)
                try self.context.save()
                log.info("Successfully updated approval status for Core Data 'Conversation' instance.")
                completion(nil)
            } catch {
                log.error("Failed to update approval status for Core Data 'Conversaton' instance: \(error)")
                completion(error)
            }
        }
    }
    
}
