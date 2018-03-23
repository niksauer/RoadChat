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

enum CommunityMessageError: Error {
    case duplicate
}

class CommunityMessage: NSManagedObject {
    
    // MARK: - Public Class Methods
    class func createOrUpdate(from response: RoadChatKit.CommunityMessage.PublicCommunityMessage, in context: NSManagedObjectContext) throws -> CommunityMessage {
        let request: NSFetchRequest<CommunityMessage> = CommunityMessage.fetchRequest()
        request.predicate = NSPredicate(format: "id = %d", response.id)
        
        do {
            let matches = try context.fetch(request)
            
            if matches.count > 0 {
                assert(matches.count >= 1, "CommunityMessage.create -- Database Inconsistency")
                
                // update existing message
                let message = matches.first!
                message.message = response.message
                message.upvotes = Int16(response.upvotes)
                
                return message
            }
        } catch {
            throw error
        }
        
        // create new message
        let message = CommunityMessage(context: context)
        message.id = Int32(response.id)
        message.locationID = Int32(response.locationID)
        message.message = response.message
        message.senderID = Int32(response.senderID)
        message.time = response.time
        message.upvotes = Int16(response.upvotes)
        
        return message
    }
    
}
