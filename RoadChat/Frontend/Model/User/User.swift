//
//  User.swift
//  RoadChat
//
//  Created by Niklas Sauer on 02.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import CoreData
import RoadChatKit

enum UserError: Error {
    case duplicate
}

class User: NSManagedObject {
    
    class func create(from prototype: RoadChatKit.User.PublicUser, in context: NSManagedObjectContext) throws -> User {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "id = %d AND username = %@", prototype.id, prototype.username)
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count >= 1, "User.create -- Database Inconsistency")
                throw UserError.duplicate
            }
        } catch {
            throw error
        }
        
        let user = User(context: context)
        user.id = Int32(prototype.id)
        user.email = prototype.email
        user.username = prototype.username
        user.registry = prototype.registry
        
        return user
    }

}
