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
    
    // MARK: - Public Class Methods
    class func createOrUpdate(from prototype: RoadChatKit.Participation.PublicParticipant, conversationID: Int, in context: NSManagedObjectContext) throws -> Participant {
        let request: NSFetchRequest<Participant> = Participant.fetchRequest()
        request.predicate = NSPredicate(format: "conversation.id = %d AND user.id = %d", conversationID, prototype.user.id)
        
        do {
            let matches = try context.fetch(request)
            
            if matches.count > 0 {
                assert(matches.count >= 1, "Participant.createOrUpdate -- Database Inconsistency")
                
                // update existing participant
                let participant = matches.first!
                participant.approvalStatus = prototype.approval.rawValue
                participant.joining = prototype.joining
                
                return participant
            }
        } catch {
            throw error
        }
        
        // create new participant
        let participant = Participant(context: context)
        participant.approvalStatus = prototype.approval.rawValue
        participant.joining = prototype.joining
        
        // set user
        let user = try User.createOrUpdate(from: prototype.user, in: context)
        participant.user = user
        
        return participant
    }

    // MARK: - Public Methods
    func setApprovalStatus(_ status: ApprovalType) {
        approvalStatus = status.rawValue
    }
    
}
