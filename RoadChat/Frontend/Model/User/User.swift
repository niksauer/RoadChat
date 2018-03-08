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
        request.predicate = NSPredicate(format: "id = %@ AND username = %@", prototype.id, prototype.username)
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count >= 1, "Transaction.createTransaction -- Database Inconsistency")
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
    
    static func create(_ user: RegisterRequest, completion: @escaping (Error?) -> Void) {
        let userService = UserService()
        
        do {
            try userService.create(user) { user, error in
                guard let user = user else {
                    completion(error!)
                    return
                }
                
                do {
                    try CredentialManager.shared.setUserID(user.id)
                } catch {
                    // pass keychain error
                    completion(error)
                }
            }
        } catch {
            // pass body encoding error
            completion(error)
        }
    }
    
    static func login(_ user: LoginRequest, completion: @escaping (Error?) -> Void) {
        let loginClient = LoginService()
        
        do {
            try loginClient.login(user) { token, error in
                guard let token = token else {
                    completion(error!)
                    return
                }
                
                do {
                    try CredentialManager.shared.setToken(token.token)
                    try CredentialManager.shared.setUserID(token.userID)
                    completion(nil)
                } catch {
                    // pass keychain error
                    completion(error)
                }
            }
        } catch {
            // pass body encoding error
            completion(error)
        }
    }

}
