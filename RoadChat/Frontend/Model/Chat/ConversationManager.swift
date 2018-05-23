//
//  ConversationManager.swift
//  RoadChat
//
//  Created by Niklas Sauer on 16.05.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import CoreData
import RoadChatKit

struct ConversationManager {
    
    // MARK: - Private Properties
    private let conversationService: ConversationService
    private let context: NSManagedObjectContext
    
    // MARK: - Initialization
    init(conversationService: ConversationService, context: NSManagedObjectContext) {
        self.conversationService = conversationService
        self.context = context
    }
    
    // MARK: - Public Methods
    func getNearbyUsers(completion: @escaping ([RoadChatKit.User.PublicUser]?, Error?) -> Void) {
        conversationService.getNearbyUsers { users, error in
            completion(users, error)
        }
    }
    
    func findConversationByRecipients(_ recipients: [RoadChatKit.User.PublicUser], requestor: User, context: NSManagedObjectContext) -> Conversation? {
        let request: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        request.predicate = NSPredicate(format: "user.id == %d", requestor.id)
        
        guard let conversations = try? context.fetch(request), conversations.count >= 1 else {
            return nil
        }
        
        struct User: Hashable {
            let id: Int
        }
        
        return conversations.first { conversation in
            if conversation.creatorID == requestor.id {
                let participants = Set(conversation.storedParticipants.map { User(id: Int($0.user!.id)) })
                let recipients = Set(participants.map { User(id: $0.id) })
                
                return participants == recipients
            } else {
                guard recipients.contains(where: { recipient in
                    recipient.id == conversation.creatorID
                }) else {
                    return false
                }
                
                let participants = Set(conversation.storedParticipants.map { User(id: Int($0.user!.id)) })
                var recipients = Set(participants.map { User(id: $0.id) })
                recipients.insert(User(id: Int(requestor.id)))
                
                return participants == recipients
            }
        }
    }
    
}
