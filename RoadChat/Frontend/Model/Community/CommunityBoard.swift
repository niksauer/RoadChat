//
//  CommunityBoard.swift
//  RoadChat
//
//  Created by Niklas Sauer on 18.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import RoadChatKit

struct CommunityBoard {
    
    // MARK: - Public Properties
    let communityService = CommunityService(credentials: CredentialManager.shared)
    
    // MARK: - Public Methods
    func postMessage(_ message: CommunityMessageRequest, completion: @escaping (Error?) -> Void) {
        do {
            try communityService.create(message) { message, error in
                guard let message = message else {
                    // pass service error
                    log.error("Failed to create post: \(error!)")
                    completion(error!)
                    return
                }
                
                do {
                    _ = try CommunityMessage.createOrUpdate(from: message, in: CoreDataStack.shared.viewContext)
                    CoreDataStack.shared.saveViewContext()
                    log.info("Successfully created Core Data 'CommunityMessage' instance.")
                    completion(nil)
                } catch {
                    // pass core data error
                    log.error("Failed to create Core Data 'CommunityMessage' instance: \(error)")
                    completion(error)
                }
            }
        } catch {
            // pass body encoding error
            log.error("Failed to send community message request: \(error)")
            completion(error)
        }
    }
    
}
