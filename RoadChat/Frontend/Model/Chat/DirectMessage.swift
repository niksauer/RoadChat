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
    class func create(from prototype: RoadChatKit.DirectMessage.PublicDirectMessage, conversationID: Int, in context: NSManagedObjectContext) throws -> DirectMessage {
        let request: NSFetchRequest<DirectMessage> = DirectMessage.fetchRequest()
        request.predicate = NSPredicate(format: "conversation.id = %d AND id = %d", conversationID, prototype.id)
        
        do {
            let matches = try context.fetch(request)
            
            if matches.count > 0 {
                assert(matches.count >= 1, "DirectMessage.create -- Database Inconsistency")
                throw DirectMessageError.duplicate
            }
        } catch {
            throw error
        }
        
        // create new message
        let message = DirectMessage(context: context)
        message.senderID = Int32(prototype.senderID)
        message.time = prototype.time
        message.message = prototype.message
        
        return message
    }
 
}
