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
    
    // MARK: - Public Static Methods
    static func create(_ message: CommunityMessageRequest, completion: @escaping (Error?) -> Void) {
        do {
            try CommunityService(credentials: CredentialManager.shared).create(message) { message, error in
                guard let message = message else {
                    // pass service error
                    log.error("Failed to create post: \(error!)")
                    completion(error!)
                    return
                }
                
                do {
                    _ = try CommunityMessage.create(from: message, in: CoreDataStack.shared.viewContext)
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
    
    // MARK: - Public Class Methods
    class func create(from response: RoadChatKit.CommunityMessage.PublicCommunityMessage, in context: NSManagedObjectContext) throws -> CommunityMessage {
        let request: NSFetchRequest<CommunityMessage> = CommunityMessage.fetchRequest()
        request.predicate = NSPredicate(format: "id = %d", response.id)
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count >= 1, "CommunityMessage.create -- Database Inconsistency")
                throw CommunityMessageError.duplicate
            }
        } catch {
            throw error
        }
        
        let post = CommunityMessage(context: context)
        post.id = Int32(response.id)
        post.locationID = Int32(response.locationID)
        post.message = response.message
        post.senderID = Int32(response.senderID)
        post.time = response.time
        post.upvotes = Int16(response.upvotes)
        
        return post
    }
    
}
