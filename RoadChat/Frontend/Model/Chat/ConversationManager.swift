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
    
}
