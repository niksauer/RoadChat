//
//  Participant.swift
//  RoadChat
//
//  Created by Niklas Sauer on 02.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import CoreData
import RoadChatKit

class Participant: NSManagedObject {
    
    class func createOrUpdate(from prototype: RoadChatKit.Participation.PublicParticipant, in context: NSManagedObjectContext) throws -> Participant {
        let request: NSFetchRequest<Participant> = Participant.fetchRequest()
        request.predicate = NSPredicate(format: "userID = %d", prototype.userID)
        
        do {
            let matches = try context.fetch(request)
            
            if matches.count > 0 {
                assert(matches.count >= 1, "Conversation.create -- Database Inconsistency")
                throw ConversationError.duplicate
            }
        } catch {
            throw error
        }
        
        let participant = Participant(context: context)
        participant.userID = Int32(prototype.userID)
        participant.approvalStatus = prototype.approvalStatus
        participant.joining = prototype.joining
        
        return participant
    }
    
}
