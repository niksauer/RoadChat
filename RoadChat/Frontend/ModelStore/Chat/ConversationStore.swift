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
                    _ = try Conversation.create(from: conversation, in: CoreDataStack.shared.viewContext)
                    CoreDataStack.shared.saveViewContext()
                } catch {
                    // pass core data error
                    log.error("Failed to create Core Data 'Conversation' entity: \(error)")
                    completion(error)
                }
            }
        } catch {
            // pass body encoding error
            log.error("Failed to send 'ConversationRequest': \(error)")
            completion(error)
        }
    }
}
