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

class CommunityMessage: NSManagedObject, ReportOwner {

    // MARK: - Public Class Methods
    class func createOrUpdate(from response: RoadChatKit.CommunityMessage.PublicCommunityMessage, in context: NSManagedObjectContext) throws -> CommunityMessage {
        let request: NSFetchRequest<CommunityMessage> = CommunityMessage.fetchRequest()
        request.predicate = NSPredicate(format: "id = %d", response.id)
        
        do {
            let matches = try context.fetch(request)
            
            if matches.count > 0 {
                assert(matches.count >= 1, "CommunityMessage.create -- Database Inconsistency")
                
                // update existing message
                let message = matches.first!
                message.title = response.title
                message.message = response.message
                message.upvotes = Int16(response.upvotes)
                message.karma = Int16(response.karma?.rawValue ?? 0)
                
                return message
            }
        } catch {
            throw error
        }
        
        // create new message
        let message = CommunityMessage(context: context)
        message.id = Int32(response.id)
        message.locationID = Int32(response.locationID)
        message.senderID = Int32(response.senderID)
        message.time = response.time
        message.title = response.title
        message.message = response.message
        message.upvotes = Int16(response.upvotes)
        message.karma = Int16(response.karma?.rawValue ?? 0)
        
        return message
    }

    // MARK: - Private Properties
    private let communityService = CommunityService(credentials: CredentialManager.shared)
    private let context = CoreDataStack.shared.viewContext
    
    // MARK: - Private Properties
    var storedKarma: KarmaType {
        return KarmaType(rawValue: Int(karma))!
    }
    
    // MARK: - ReportOwner Protocol
    var logDescription: String {
        return "'CommunityMessage' [id: '\(id)']"
    }
    
    // MARK: - Public Methods
    func upvote(completion: ((Error?) -> Void)?) {
        communityService.upvote(messageID: Int(id)) { error in
            guard error == nil else {
                // pass service error
                let report = Report(.failedServerOperation(.upvote, resource: nil, isMultiple: false, error: error!), owner: self)
                log.error(report)
                completion?(error!)
                return
            }
            
            switch self.storedKarma {
            case .upvote:
                self.setKarma(.neutral, completion: completion)
            case .neutral:
                self.setKarma(.upvote, completion: completion)
            case .downvote:
                self.setKarma(.upvote, completion: completion)
            }
        }
    }
    
    func downvote(completion: ((Error?) -> Void)?) {
        communityService.downvote(messageID: Int(id)) { error in
            guard error == nil else {
                // pass service error
                let report = Report(.failedServerOperation(.downvote, resource: nil, isMultiple: false, error: error!), owner: self)
                log.error(report)
                completion?(error!)
                return
            }
            
            switch self.storedKarma {
            case .upvote:
                self.setKarma(.downvote, completion: completion)
            case .neutral:
                self.setKarma(.downvote, completion: completion)
            case .downvote:
                self.setKarma(.neutral, completion: completion)
            }
        }
    }
    
    // MARK: - Private Methods
    private func setKarma(_ karma: KarmaType, completion: ((Error?) -> Void)?) {
        do {
            switch storedKarma {
            case .upvote:
                switch karma {
                case .neutral:
                    self.upvotes -= 1
                case .downvote:
                    self.upvotes -= 2
                default:
                    break
                }
            case .neutral:
                switch karma {
                case .upvote:
                    self.upvotes += 1
                case .downvote:
                    self.upvotes -= 1
                default:
                    break
                }
            case .downvote:
                switch karma {
                case .upvote:
                    self.upvotes += 2
                case .neutral:
                    self.upvotes += 1
                default:
                    break
                }
            }
            
            self.karma = Int16(karma.rawValue)
            try self.context.save()
            let report: Report
            
            switch karma {
            case .upvote:
                report = Report(.successfulCoreDataOperation(.upvote, resource: nil, isMultiple: false), owner: self)
            case .neutral:
                report = Report(.successfulCoreDataOperation(.neutralize, resource: nil, isMultiple: false), owner: self)
            case .downvote:
                report = Report(.successfulCoreDataOperation(.downvote, resource: nil, isMultiple: false), owner: self)
            }
            
            log.debug(report)
            completion?(nil)
        } catch {
            let report = Report(.failedCoreDataOperation(.update, resource: nil, isMultiple: false, error: error), owner: self)
            log.error(report)
            completion?(error)
        }
    }
    
}
