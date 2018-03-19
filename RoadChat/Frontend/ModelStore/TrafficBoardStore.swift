//
//  TrafficStore.swift
//  RoadChat
//
//  Created by Phillip Rust on 10.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import RoadChatKit

struct TrafficBoardStore {
    
    private let trafficService = TrafficService()
    
    func create(_ post: TrafficMessageRequest, completion: @escaping (Error?) -> Void) {
        do {
            try trafficService.create(post) { post, error in
                guard let post = post else {
                    // pass service error
                    log.error("Failed to create post: \(error!)")
                    completion(error!)
                    return
                }
                
                do {
                    _ = try TrafficMessage.create(from: post, in: CoreDataStack.shared.viewContext)
                    CoreDataStack.shared.saveViewContext()
                    log.info("Successfully created Core Date 'TrafficMessage' instance.")
                    completion(nil)
                } catch {
                    // pass core data error
                    log.error("Failed to create Core Data 'TrafficMessage' instance: \(error)")
                    completion(error)
                }
            }
        } catch {
            // pass body encoding error
            log.error("Failed to send traffic message request: \(error)")
            completion(error)
        }
    }
     
}

