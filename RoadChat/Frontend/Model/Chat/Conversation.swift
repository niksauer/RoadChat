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
                
                let conversation = matches.first!
                conversation.title = response.title
                
                return conversation
            }
        } catch {
            throw error
        }
        
        let conversation = Conversation(context: context)
        conversation.id = Int32(response.id)
        conversation.creatorID = Int32(response.creatorID)
        conversation.title = response.title
        conversation.creation = response.creation
        
        return conversation
    }
    
    // MARK: - Public Properties
    let conversationService = ConversationService(credentials: CredentialManager.shared)
    
    var storedParticipants: [Participant] {
        return Array(participants!) as! [Participant]
    }
    
    // MARK: - Initialization
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        
        update(completion: nil)
        getMessages(completion: nil)
        getParticipants(completion: nil)
    }
    
    // MARK: - Public Methods
    func update(completion: ((Error?) -> Void)?) {
        conversationService.get(conversationID: Int(id)) { conversation, error in
            guard let conversation = conversation else {
                // pass service error
                log.error("Failed to update conversation '\(self.id)': \(error!)")
                completion?(error!)
                return
            }
            
            do {
                _ = try Conversation.createOrUpdate(from: conversation, in: CoreDataStack.shared.viewContext)
                CoreDataStack.shared.saveViewContext()
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

            CoreDataStack.shared.viewContext.delete(self)
            CoreDataStack.shared.saveViewContext()
            log.info("Successfully deleted Core Data 'Conversation' instance.")
            completion(nil)
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
            
            CoreDataStack.shared.persistentContainer.performBackgroundTask { context in
                _ = messages.map {
                    do {
                        _ = try DirectMessage.create(from: $0, conversation: self, in: context)
                    } catch {
                        log.error("Failed to create Core Data 'DirectMessage' instance: \(error)")
                    }
                }
                
//                _ = messages.map { try? DirectMessage.create(from: $0, conversation: self, in: context) }
                
                if context.hasChanges {
                    do {
                        try context.save()
                        log.info("Successfully saved created Core Data 'DirectMessage' instances.")
                        
                        OperationQueue.main.addOperation {
                            completion?(nil)
                        }
                    } catch {
                        log.error("Failed to save Core Data 'DirectMessage' instances: \(error)")
                        
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
                    _ = try DirectMessage.create(from: message, conversation: self, in: CoreDataStack.shared.viewContext)
                    CoreDataStack.shared.saveViewContext()
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
            
            CoreDataStack.shared.persistentContainer.performBackgroundTask { context in
                _ = participants.map {
                    do {
                        _ = try Participant.createOrUpdate(from: $0, conversation: self, in: context)
                    } catch {
                        log.error("Failed to create Core Data 'Participant' instance: \(error)")
                    }
                }
                
//                _ = participants.map { try? Participant.createOrUpdate(from: $0, conversation: self, in: context) }
                
                if context.hasChanges {
                    do {
                        try context.save()
                        log.info("Successfully saved created Core Data 'Participant' instances.")
                        
                        OperationQueue.main.addOperation {
                            completion?(nil)
                        }
                    } catch {
                        log.error("Failed to save Core Data 'Participant' instances: \(error)")
                        
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
            
            participation.setApprovalStatus(.accepted)
            CoreDataStack.shared.saveViewContext()
            
            completion(nil)
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
            
            participation.setApprovalStatus(.denied)
            CoreDataStack.shared.saveViewContext()
            
            completion(nil)
        }
    }
    
}
