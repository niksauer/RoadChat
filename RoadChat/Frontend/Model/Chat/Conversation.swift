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
    case duplicate
}

class Conversation: NSManagedObject {
    
    let conversationService = ConversationService()
    
    class func createOrUpdate(from prototype: RoadChatKit.Conversation.PublicConversation, in context: NSManagedObjectContext) throws -> Conversation {
        let request: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        request.predicate = NSPredicate(format: "id = %d", prototype.id)
        
        do {
            let matches = try context.fetch(request)
            
            if matches.count > 0 {
                assert(matches.count >= 1, "Conversation.create -- Database Inconsistency")
                throw ConversationError.duplicate
                
                // add update logic by adding lastChanged property
//                let conversation = matches.first!
//                conversation.title = prototype.title
                
//                return conversation  
            }
        } catch {
            throw error
        }
        
        let conversation = Conversation(context: context)
        conversation.id = Int32(prototype.id)
        conversation.creatorID = Int32(prototype.creatorID)
        conversation.title = prototype.title
        conversation.creation = prototype.creation
        
        return conversation
    }
    
    func accept(completion: @escaping (Error?) -> Void) {
        conversationService.accept(conversationID: Int(id)) { error in
            guard error == nil else {
                log.error("Failed to accept conversation '\(self.id)': \(error!)")
                completion(error!)
                return
            }
            
            CoreDataStack.shared.saveViewContext()
            completion(nil)
        }
    }
    
    func deny(completion: @escaping (Error?) -> Void) {
        conversationService.delete(conversationID: Int(id)) { error in
            guard error == nil else {
                log.error("Failed to deny conversation '\(self.id)': \(error!)")
                completion(error!)
                return
            }
            
            CoreDataStack.shared.saveViewContext()
            completion(nil)
        }
    }
    
    func delete(completion: @escaping (Error?) -> Void) {
        conversationService.delete(conversationID: Int(id)) { error in
            guard error == nil else {
                log.error("Failed to delete conversation '\(self.id)': \(error!)")
                completion(error!)
                return
            }
    
            CoreDataStack.shared.viewContext.delete(self)
            CoreDataStack.shared.saveViewContext()
            completion(nil)
        }
    }
 
    func getMessages(completion: @escaping (Error?) -> Void) {
        conversationService.getMessages(conversationID: Int(id)) { messages, error in
            guard let messages = messages else {
                log.error("Failed to retrieve messages for conversation '\(self.id)': \(error!)")
                completion(error!)
                return
            }
            
            CoreDataStack.shared.persistentContainer.performBackgroundTask { context in
                _ = messages.map {
                    do {
                        _ = try DirectMessage.create(from: $0, in: context)
                    } catch {
                        log.error("Failed to create Core Data 'DirectMessage' instance: \(error)")
                    }
                }
                
//                _ = messages.map { try? DirectMessage.create(from: $0, in: context) }
                
                if context.hasChanges {
                    do {
                        try context.save()
                        log.info("Successfully saved created Core Data 'DirectMessage' instances.")
                        
                        OperationQueue.main.addOperation {
                            completion(nil)
                        }
                    } catch {
                        log.error("Failed to save Core Data 'DirectMessage' instances: \(error)")
                        
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

    func createMessage(_ message: DirectMessageRequest, completion: @escaping (Error?) -> Void) {
        do {
            try conversationService.createMessage(message, conversationID: Int(id)) { error in
                guard error == nil else {
                    // pass service error
                    log.error("Failed to create message: \(error!)")
                    completion(error!)
                    return
                }
                
//                do {
//                    _ = try DirectMessage.create(from: <#T##DirectMessage.PublicDirectMessage#>, in: CoreDataStack.shared.viewContext)
//                    CoreDataStack.shared.saveViewContext()
//                    log.info("Successfully created Core Data 'DirectMessage' instance.")
//                    completion(nil)
//                } catch {
//                    // pass core data error
//                    log.error("Failed to create Core Data 'Conversation' instance: \(error)")
//                    completion(error)
//                }
            }
        } catch {
            // pass body encoding error
            log.error("Failed to send 'DirectMessageRequest': \(error)")
            completion(error)
        }
    }
    
    func getParticipants(completion: @escaping (Error?) -> Void) {
        conversationService.getParticipants(conversationID: Int(id)) { participants, error in
            guard let participants = participants else {
                // pass service error
                log.error("Failed to get participants for conversation '\(self.id)': \(error!)")
                completion(error!)
                return
            }
            
            CoreDataStack.shared.persistentContainer.performBackgroundTask { context in
                _ = participants.map {
                    do {
                        _ = try Participant.createOrUpdate(from: $0, in: context)
                    } catch {
                        log.error("Failed to create Core Data 'Participant' instance: \(error)")
                    }
                }
                
//                _ = conversations.map { _ = try? Conversation.create(from: $0, in: context) }
                
                if context.hasChanges {
                    do {
                        try context.save()
                        log.info("Successfully saved created Core Data 'Participant' instances.")
                        
                        OperationQueue.main.addOperation {
                            completion(nil)
                        }
                    } catch {
                        log.error("Failed to save Core Data 'Participant' instances: \(error)")
                        
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
