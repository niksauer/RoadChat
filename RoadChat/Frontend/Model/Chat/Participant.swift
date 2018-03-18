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
    class func createOrUpdate(from response: RoadChatKit.Participation.PublicParticipant, conversation: Conversation, in context: NSManagedObjectContext) throws -> Participant {
        let request: NSFetchRequest<Participant> = Participant.fetchRequest()
        request.predicate = NSPredicate(format: "conversation.id = %d AND userID = %d", conversation.id, response.userID)
        
        do {
            let matches = try context.fetch(request)
            
            if matches.count > 0 {
                assert(matches.count >= 1, "Participant.createOrUpdate -- Database Inconsistency")
                
                let participant = matches.first!
                participant.approvalStatus = response.approvalStatus
                participant.joining = response.joining
                
                return participant
            }
        } catch {
            throw error
        }
        
        let participant = Participant(context: context)
        participant.userID = Int32(response.userID)
        participant.approvalStatus = response.approvalStatus
        participant.joining = response.joining
        participant.conversation = conversation
        
        return participant
    }

    // MARK: - Public Methods
    func setApprovalStatus(_ status: ApprovalStatus) {
        approvalStatus = status.rawValue
    }
    
}
