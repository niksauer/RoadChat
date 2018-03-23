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
    class func createOrUpdate(from response: RoadChatKit.Profile.PublicProfile, userID: Int, in context: NSManagedObjectContext) throws -> Profile {
        let request: NSFetchRequest<Profile> = Profile.fetchRequest()
        request.predicate = NSPredicate(format: "user.id = %d", userID)
        
        do {
            let matches = try context.fetch(request)
            
            if matches.count > 0 {
                assert(matches.count >= 1, "Profile.createOrUpdate -- Database Inconsistency")
                
                let profile = matches.first!
                profile.firstName = response.firstName
                profile.lastName = response.lastName
                profile.birth = response.birth
                profile.sex = response.sex
                profile.streetName = response.streetName
                profile.postalCode = Int16(response.postalCode ?? 0)
                profile.country = response.country
                profile.biography = response.biography
                
                return profile
            }
        } catch {
            throw error
        }
        
        let profile = Profile(context: context)
        profile.firstName = response.firstName
        profile.lastName = response.lastName
        profile.birth = response.birth
        profile.sex = response.sex
        profile.streetName = response.streetName
        profile.postalCode = Int16(response.postalCode ?? 0)
        profile.country = response.country
        profile.biography = response.biography
    
        return profile
    }
    
}
