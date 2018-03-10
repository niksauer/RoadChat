//
//  ConversationStore.swift
//  RoadChat
//
//  Created by Niklas Sauer on 09.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import RoadChatKit

struct ConversationStore {
    
    private let conversationService = ConversationService()
    private let userService = UserService()
    
    func create(_ conversation: ConversationRequest, completion: @escaping (Error?) -> Void) {
        do {
            try conversationService.create(conversation) { conversation, error in
                guard let conversation = conversation else {
                    // pass service error
                    log.error("Failed to create conversation: \(error!)")
                    completion(error!)
                    return
                }
                
                do {
                    _ = try Conversation.createOrUpdate(from: conversation, in: CoreDataStack.shared.viewContext)
                    CoreDataStack.shared.saveViewContext()
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

    func updateConversations(completion: @escaping (Error?) -> Void) {
        guard let userID = CredentialManager.shared.getUserID() else {
            log.error("No userID set, i.e. not logged in, but attempting to retrieve personal conversations.")
            completion(CredentialError.noUserIDSet)
            return
        }
        
        userService.getConversations(userID: userID) { conversations, error in
            guard let conversations = conversations else {
                // pass service error
                log.error("Failed to get conversations for user '\(userID)': \(error!)")
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
