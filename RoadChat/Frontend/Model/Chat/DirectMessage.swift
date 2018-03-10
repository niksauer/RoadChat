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

class DirectMessage: NSManagedObject {
    
//    class func create(from prototype: RoadChatKit.DirectMessageRequest, in context: NSManagedObjectContext) -> DirectMessage {
//        guard let userID = CredentialManager.shared.getUserID() else {
//            //
//            return
//        }
//        
//        let message = DirectMessage(context: context)
//        message.senderID = Int32(userID)
//        message.time = prototype.time
//        message.message = prototype.message
//        
//        return message
//    }
    
    class func create(from prototype: RoadChatKit.DirectMessage.PublicDirectMessage, in context: NSManagedObjectContext) throws -> DirectMessage {
        let request: NSFetchRequest<DirectMessage> = DirectMessage.fetchRequest()
        request.predicate = NSPredicate(format: "senderID = %d", prototype.senderID)
        
        do {
            let matches = try context.fetch(request)
            
            if matches.count > 0 {
                assert(matches.count >= 1, "Conversation.create -- Database Inconsistency")
                throw ConversationError.duplicate
            }
        } catch {
            throw error
        }
        
        let message = DirectMessage(context: context)
        message.senderID = Int32(prototype.senderID)
        message.time = prototype.time
        message.message = prototype.message
        
        return message
    }
 
}
