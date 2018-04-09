//
//  TrafficMessage.swift
//  RoadChat
//
//  Created by Niklas Sauer on 02.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import CoreData
import RoadChatKit

enum TrafficError: Error {
    case duplicate
}

class TrafficMessage: NSManagedObject {
    
    class func createOrUpdate(from prototype: RoadChatKit.TrafficMessage.PublicTrafficMessage, in context: NSManagedObjectContext) throws -> TrafficMessage {
        let request: NSFetchRequest<TrafficMessage> = TrafficMessage.fetchRequest()
        request.predicate = NSPredicate(format: "id = %d", prototype.id)
        
        do {
            let matches = try context.fetch(request)
            
            if matches.count > 0 {
                assert(matches.count >= 1, "Transaction.createTransaction -- Database Inconsistency")
                
                // update existing message
                let message = matches.first!
                message.type = prototype.type
                message.message = prototype.message
                message.validations = Int16(prototype.validations)
                message.upvotes = Int16(prototype.upvotes)
                message.karma = Int16(prototype.karma.rawValue)
                
                return message
            }
        } catch {
            throw error
        }
        
        // create new message
        let message = TrafficMessage(context: context)
        message.id = Int32(prototype.id)
        message.senderID = Int32(prototype.senderID)
        message.locationID = Int32(prototype.locationID)
        message.time = prototype.time
        message.type = prototype.type
        message.message = prototype.message
        message.validations = Int16(prototype.validations)
        message.upvotes = Int16(prototype.upvotes)
        message.karma = Int16(prototype.karma.rawValue)
        
        return message
    }
    
}
