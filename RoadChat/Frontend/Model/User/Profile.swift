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
                
                // update existing profile
                let profile = matches.first!
                profile.firstName = prototype.firstName
                profile.lastName = prototype.lastName
                profile.birth = prototype.birth
                profile.sex = prototype.sex?.rawValue
                profile.streetName = prototype.streetName
                profile.streetNumber = Int32(prototype.streetNumber ?? -1)
                profile.postalCode = Int32(prototype.postalCode ?? -1)
                profile.city = prototype.city
                profile.country = prototype.country
                profile.biography = prototype.biography
                
                return profile
            }
        } catch {
            throw error
        }
        
        // create new profile
        let profile = Profile(context: context)
        profile.firstName = prototype.firstName
        profile.lastName = prototype.lastName
        profile.birth = prototype.birth
        profile.sex = prototype.sex?.rawValue
        profile.streetName = prototype.streetName
        profile.streetNumber = Int32(prototype.streetNumber ?? -1)
        profile.postalCode = Int32(prototype.postalCode ?? -1)
        profile.city = prototype.city
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
