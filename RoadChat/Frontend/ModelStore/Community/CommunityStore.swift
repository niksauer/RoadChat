//
//  CommunityStore.swift
//  RoadChat
//
//  Created by Malcolm Malam on 09.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import RoadChatKit

struct CommunityStore {
    
    private let communityService = CommunityService()
    
    func create(_ post: CommunityMessageRequest, completion: @escaping (Error?) -> Void) {
        do {
            try communityService.create(post) { post, error in
                guard let post = post else {
                    // pass service error
                    log.error("Failed to create post: \(error!)")
                    completion(error!)
                    return
                }
                
                do {
                    _ = try CommunityMessage.create(from: post, in: CoreDataStack.shared.viewContext)
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
