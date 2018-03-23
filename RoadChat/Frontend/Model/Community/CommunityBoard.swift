//
//  CommunityBoard.swift
//  RoadChat
//
//  Created by Niklas Sauer on 18.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import RoadChatKit
import CoreData

struct CommunityBoard: ReportOwner {
    
    // MARK: - Private Properties
    private let communityService: CommunityService
    private let context: NSManagedObjectContext
    
    // MARK: - ReportOwner Protocol
    var logDescription: String {
        return "'CommunityBoard'"
    }
    
    // MARK: - Initialization
    init(communityService: CommunityService, context: NSManagedObjectContext) {
        self.communityService = communityService
        self.context = context
    }
    
    // MARK: - Public Methods
    func postMessage(_ message: CommunityMessageRequest, completion: @escaping (Error?) -> Void) {
        do {
            try communityService.create(message) { message, error in
                guard let message = message else {
                    // pass service error
                    let report = Report(.failedServerOperation(.create, resource: "CommunityMessage", isMultiple: false, error: error!), owner: self)
                    log.error(report)
                    completion(error!)
                    return
                }
                
                do {
                    _ = try CommunityMessage.createOrUpdate(from: message, in: self.context)
                    try self.context.save()
                    let report = Report(.successfulCoreDataOperation(.create, resource: "CommunityMessage", isMultiple: false), owner: self)
                    log.debug(report)
                    completion(nil)
                } catch {
                    // pass core data error
                    let report = Report(.failedCoreDataOperation(.create, resource: "CommunityMessage", isMultiple: false, error: error), owner: self)
                    log.error(report)
                    completion(error)
                }
            }
        } catch {
            // pass body encoding error
            let report = Report(.failedServerRequest(requestType: "CommunityMessageRequest", error: error), owner: self)
            log.error(report)
            completion(error)
        }
    }
    
}
