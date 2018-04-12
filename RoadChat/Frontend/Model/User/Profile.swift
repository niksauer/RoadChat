//
//  Profile.swift
//  RoadChat
//
//  Created by Niklas Sauer on 02.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import CoreData
import RoadChatKit

class Profile: NSManagedObject {
    
    // MARK: - Public Class Methods
    class func createOrUpdate(from prototype: RoadChatKit.Profile.PublicProfile, userID: Int, in context: NSManagedObjectContext) throws -> Profile {
        let request: NSFetchRequest<Profile> = Profile.fetchRequest()
        request.predicate = NSPredicate(format: "user.id = %d", userID)
        
        do {
            let matches = try context.fetch(request)
            
            if matches.count > 0 {
                assert(matches.count >= 1, "Profile.createOrUpdate -- Database Inconsistency")
                
                let profile = matches.first!
                profile.firstName = prototype.firstName
                profile.lastName = prototype.lastName
                profile.birth = prototype.birth
                profile.sex = prototype.sex?.rawValue
                profile.streetName = prototype.streetName
                profile.postalCode = Int16(prototype.postalCode ?? 0)
                profile.country = prototype.country
                profile.biography = prototype.biography
                
                return profile
            }
        } catch {
            throw error
        }
        
        let profile = Profile(context: context)
        profile.firstName = prototype.firstName
        profile.lastName = prototype.lastName
        profile.birth = prototype.birth
        profile.sex = prototype.sex?.rawValue
        profile.streetName = prototype.streetName
        profile.postalCode = Int16(prototype.postalCode ?? 0)
        profile.country = prototype.country
        profile.biography = prototype.biography
    
        return profile
    }
    
    // MARK: - Public Properties
    var storedSex: SexType? {
        guard let sex = sex else {
            return nil
        }
        
        return SexType(rawValue: sex)!
    }
    
}
