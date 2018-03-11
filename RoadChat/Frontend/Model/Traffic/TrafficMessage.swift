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
    
    class func create(from prototype: RoadChatKit.TrafficMessage.PublicTrafficMessage, in context: NSManagedObjectContext) throws -> TrafficMessage {
        let request: NSFetchRequest<TrafficMessage> = TrafficMessage.fetchRequest()
        request.predicate = NSPredicate(format: "id = %d", prototype.id)
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count >= 1, "Transaction.createTransaction -- Database Inconsistency")
                throw TrafficError.duplicate
            }
        } catch {
            throw error
        }
        
        let post = TrafficMessage(context: context)
        post.id = Int32(prototype.id)
        post.senderID = Int32(prototype.senderID)
        post.locationID = Int32(prototype.locationID)
        post.type = prototype.type
        post.time = prototype.time
        post.message = prototype.message
        post.validations = Int16(prototype.validations)
        post.upvotes = Int16(prototype.upvotes)
        
        return post
    }
    
}
