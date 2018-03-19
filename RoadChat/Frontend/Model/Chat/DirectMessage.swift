//
//  DirectMessage.swift
//  RoadChat
//
//  Created by Niklas Sauer on 02.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import CoreData
import RoadChatKit

enum DirectMessageError: Error {
    case duplicate
}

class DirectMessage: NSManagedObject {
    
    // MARK: - Public Class Methods
    class func create(from response: RoadChatKit.DirectMessage.PublicDirectMessage, conversation: Conversation, in context: NSManagedObjectContext) throws -> DirectMessage {
        let request: NSFetchRequest<DirectMessage> = DirectMessage.fetchRequest()
        request.predicate = NSPredicate(format: "conversation.id = %d AND id = %d", conversation.id, response.id)
        
        do {
            let matches = try context.fetch(request)
            
            if matches.count > 0 {
                assert(matches.count >= 1, "DirectMessage.create -- Database Inconsistency")
                throw DirectMessageError.duplicate
            }
        } catch {
            throw error
        }
        
        let message = DirectMessage(context: context)
        message.senderID = Int32(response.senderID)
        message.time = response.time
        message.message = response.message
        message.conversation = conversation
        
        return message
    }
 
}
