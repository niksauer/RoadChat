//
//  Settings.swift
//  RoadChat
//
//  Created by Niklas Sauer on 02.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import CoreData
import RoadChatKit

class Settings: NSManagedObject {
    
    // MARK: - Public Class Methods
    class func createOrUpdate(from prototype: RoadChatKit.Settings.PublicSettings, userID: Int, in context: NSManagedObjectContext) throws -> Settings {
        let request: NSFetchRequest<Settings> = Settings.fetchRequest()
        request.predicate = NSPredicate(format: "user.id = %d", userID)
        
        do {
            let matches = try context.fetch(request)
            
            if matches.count > 0 {
                assert(matches.count >= 1, "Settings.createOrUpdate -- Database Inconsistency")
                
                // update existing settings
                let settings = matches.first!
                settings.communityRadius = Int16(prototype.communityRadius)
                settings.trafficRadius = Int16(prototype.trafficRadius)
                
                return settings
            }
        } catch {
            throw error
        }
        
        // create new settings
        let settings = Settings(context: context)
        settings.communityRadius = Int16(prototype.communityRadius)
        settings.trafficRadius = Int16(prototype.trafficRadius)
        
        return settings
    }
    
    // MARK: - Private Properties
    private let userService = UserService(config: DependencyContainer().config)
    private let context = CoreDataStack.shared.viewContext
    
    // MARK: - Public Methods
    func save(completion: @escaping (Error?) -> Void) {
        do {
            let request = SettingsRequest(communityRadius: Int(communityRadius), trafficRadius: Int(trafficRadius))
            
            try userService.updateSettings(userID: Int(self.user!.id), to: request) { error in
                guard error == nil else {
                    // pass service error
                    let report = Report(.failedServerOperation(.update, resource: "Settings", isMultiple: false, error: error!), owner: self.user!)
                    log.error(report)
                    completion(error!)
                    return
                }
                
                do {
                    try self.context.save()
                    let report = Report(.successfulCoreDataOperation(.update, resource: "Settings", isMultiple: false), owner: self.user!)
                    log.debug(report)
                    completion(nil)
                } catch {
                    // pass core data error
                    let report = Report(.failedCoreDataOperation(.update, resource: "Settings", isMultiple: false, error: error), owner: self.user!)
                    log.error(report)
                    completion(error)
                }
            }
        } catch {
            // pass body encoding error
            let report = Report(.failedServerRequest(requestType: "SettingsRequest", error: error), owner: user!)
            log.error(report)
            completion(error)
        }
    }
    
}
