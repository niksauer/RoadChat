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
    
    class func create(from prototype: RoadChatKit.Conversation.PublicConversation, in context: NSManagedObjectContext) throws -> Conversation {
        let request: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        request.predicate = NSPredicate(format: "id = %d", prototype.id)
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count >= 1, "Conversation.create -- Database Inconsistency")
                throw ConversationError.duplicate
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
    
}
