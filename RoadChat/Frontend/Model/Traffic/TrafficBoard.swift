//
//  TrafficBoard.swift
//  RoadChat
//
//  Created by Niklas Sauer on 20.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import RoadChatKit
import CoreData

struct TrafficBoard: ReportOwner {
    
    // MARK: - Private Properties
    private let trafficService: TrafficService
    private let context: NSManagedObjectContext
    private let locationManager: LocationManager
    
    // MARK: - ReportOwner Protocol
    var logDescription: String {
        return "'TrafficBoard'"
    }
    
    // MARK: - Initialization
    init(trafficService: TrafficService, context: NSManagedObjectContext, locationManager: LocationManager) {
        self.trafficService = trafficService
        self.context = context
        self.locationManager = locationManager
    }
    
    // MARK: - Public Methods
    func postMessage(type: TrafficType, message: String?, time: Date, completion: @escaping (Error?) -> Void) {
        guard let location = locationManager.lastLocation else {
            completion(LocationError.noLocation)
            return
        }
        
        do {
            let request = TrafficMessageRequest(type: type, time: time, message: message, location: RoadChatKit.Location(coreLocation: location))
            
            try trafficService.create(request) { message, error in
                guard let message = message else {
                    // pass service error
                    let report = Report(.failedServerOperation(.create, resource: "TrafficMessage", isMultiple: false, error: error!), owner: self)
                    log.error(report)
                    completion(error!)
                    return
                }
                
                do {
                    _ = try TrafficMessage.createOrUpdate(from: message, in: self.context)
                    try self.context.save()
                    let report  = Report(.successfulCoreDataOperation(.create, resource: "TrafficMessage", isMultiple: false), owner: self)
                    log.debug(report)
                    completion(nil)
                } catch {
                    // pass core data error
                    let report = Report(.failedCoreDataOperation(.create, resource: "TrafficMessage", isMultiple: false, error: error), owner: self)
                    log.error(report)
                    completion(error)
                }
            }
        } catch {
            // pass body encoding error
            let report = Report(.failedServerRequest(requestType: "TrafficMessageRequest", error: error), owner: self)
            log.error(report)
            completion(error)
        }
    }
    
    func getMessages(completion: ((Error?) -> Void)?) {
        trafficService.index { messages, error in
            guard let messages = messages else {
                // pass service error
                let report = Report(.failedServerOperation(.retrieve, resource: "TrafficMessage", isMultiple: true, error: error!), owner: self)
                log.error(report)
                completion?(error!)
                return
            }
            
            for message in messages {
                do {
                    _ = try TrafficMessage.createOrUpdate(from: message, in: self.context)
                } catch {
                    let report = Report(.failedCoreDataOperation(.create, resource: "TrafficMessage", isMultiple: true, error: error), owner: self)
                    log.error(report)
                }
            }

            do {
                try self.context.save()
                let report = Report(.successfulCoreDataOperation(.retrieve, resource: "TrafficMessage", isMultiple: true), owner: self)
                log.debug(report)
                completion?(nil)
            } catch {
                let report = Report(.failedCoreDataOperation(.retrieve, resource: "TrafficMessage", isMultiple: true, error: error), owner: self)
                log.error(report)
                completion?(error)
            }
        }
    }
    
}
