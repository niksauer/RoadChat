//
//  TrafficMessage.swift
//  RoadChat
//
//  Created by Niklas Sauer on 02.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import CoreData
import RoadChatKit

enum TrafficError: Error {
    case duplicate
}

class TrafficMessage: NSManagedObject, ReportOwner {
    
    class func createOrUpdate(from prototype: RoadChatKit.TrafficMessage.PublicTrafficMessage, in context: NSManagedObjectContext) throws -> TrafficMessage {
        let request: NSFetchRequest<TrafficMessage> = TrafficMessage.fetchRequest()
        request.predicate = NSPredicate(format: "id = %d", prototype.id)
        
        do {
            let matches = try context.fetch(request)
            
            if matches.count > 0 {
                assert(matches.count >= 1, "Transaction.createTransaction -- Database Inconsistency")
                
                // update existing message
                let message = matches.first!
                message.type = prototype.type.rawValue
                message.message = prototype.message
                message.validations = Int16(prototype.validations)
                message.upvotes = Int16(prototype.upvotes)
                message.karma = Int16(prototype.karma.rawValue)
                
                return message
            }
        } catch {
            throw error
        }
        
        // create new message
        let message = TrafficMessage(context: context)
        message.id = Int32(prototype.id)
        message.senderID = Int32(prototype.senderID)
        message.locationID = Int32(prototype.locationID)
        message.time = prototype.time
        message.type = prototype.type.rawValue
        message.message = prototype.message
        message.validations = Int16(prototype.validations)
        message.upvotes = Int16(prototype.upvotes)
        message.karma = Int16(prototype.karma.rawValue)
        
        return message
    }
    
    // MARK: - Private Properties
    private let trafficService = TrafficService(credentials: CredentialManager.shared)
    private let context = CoreDataStack.shared.viewContext
    
    // MARK: - Private Properties
    var storedKarma: KarmaType {
        return KarmaType(rawValue: Int(karma))!
    }
    
    var storedType: TrafficType {
        return TrafficType(rawValue: String(type!))!
    }
    
    // MARK: - ReportOwner Protocol
    var logDescription: String {
        return "'TrafficMessage' [id: '\(id)']"
    }
    
    // MARK: - Public Methods
    func upvote(completion: ((Error?) -> Void)?) {
        trafficService.upvote(messageID: Int(id)) { error in
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
        trafficService.downvote(messageID: Int(id)) { error in
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
