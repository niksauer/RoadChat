//
//  CommunityMessage.swift
//  RoadChat
//
//  Created by Niklas Sauer on 02.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import CoreData
import RoadChatKit

enum CommunityError: Error {
    case duplicate
}

class CommunityMessage: NSManagedObject {
    
    class func create(from prototype: RoadChatKit.CommunityMessage.PublicCommunityMessage, in context: NSManagedObjectContext) throws -> CommunityMessage {
        let request: NSFetchRequest<CommunityMessage> = CommunityMessage.fetchRequest()
        request.predicate = NSPredicate(format: "id = %d", prototype.id)
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count >= 1, "Transaction.createTransaction -- Database Inconsistency")
                throw CommunityError.duplicate
            }
        } catch {
            throw error
        }
        
        let post = CommunityMessage(context: context)
        post.id = Int32(prototype.id)
        post.locationID = Int32(prototype.locationID)
        post.message = prototype.message
        post.senderID = Int32(prototype.senderID)
        post.time = prototype.time.timeIntervalSince1970
        post.upvotes = Int16(prototype.upvotes)
        
        return post
    }
    
    
}
