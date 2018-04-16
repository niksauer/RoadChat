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
    
}
