//
//  UserManager.swift
//  RoadChat
//
//  Created by Niklas Sauer on 19.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import CoreData
import RoadChatKit

struct UserManager {
    
    // MARK: - Private Properties
    private let userService: UserService
    private let context: NSManagedObjectContext
    
    // MARK: - Initialization
    init(userService: UserService, context: NSManagedObjectContext) {
        self.userService = userService
        self.context = context
    }
    
    // MARK: - Public Methods
    func createUser(_ user: RegisterRequest, completion: @escaping (Error?) -> Void) {
        do {
            try userService.create(user) { user, error in
                guard let user = user else {
                    // pass service error
                    let report = Report(ReportType.failedServerOperation(.create, resource: "User", isMultiple: false, error: error!), owner: nil)
                    log.error(report)
                    completion(error!)
                    return
                }
                
                do {
                    _ = try User.createOrUpdate(from: user, in: self.context)
                    try self.context.save()
                    
                    let report = Report(ReportType.successfulCoreDataOperation(.create, resource: "User", isMultiple: false), owner: nil)
                    log.debug(report)
                    completion(nil)
                } catch {
                    // pass core data error
                    let report = Report(ReportType.failedCoreDataOperation(.create, resource: "User", isMultiple: false, error: error), owner: nil)
                    log.error(report)
                    completion(error)
                }
            }
        } catch {
            // pass body encoding error
            let report = Report(ReportType.failedServerRequest(requestType: "RegisterRequest", error: error), owner: nil)
            log.error(report)
            completion(error)
        }
    }
    
    func findUserById(_ id: Int, context: NSManagedObjectContext, completion: @escaping (User?, Error?) -> Void) {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "id = %d", id)
        
        func fetchUserById(_ id: Int, completion: @escaping (User?, Error?) -> Void) {
            userService.get(userID: id) { user, error in
                guard let user = user else {
                    // pass service error
                    let report = Report(ReportType.failedServerOperation(.retrieve, resource: "User", isMultiple: false, error: error!), owner: nil)
                    log.error(report)
                    completion(nil, error!)
                    return
                }
                
                do {
                    let user = try User.createOrUpdate(from: user, in: self.context)
                    try self.context.save()
                    let report = Report(ReportType.successfulCoreDataOperation(.retrieve, resource: "User", isMultiple: false), owner: nil)
                    log.debug(report)
                    completion(user, nil)
                } catch {
                    // pass core data error
                    let report = Report(ReportType.failedCoreDataOperation(.retrieve, resource: "User", isMultiple: false, error: error), owner: nil)
                    log.error(report)
                    completion(nil, error)
                }
            }
        }
        
        do {
            guard let user = try context.fetch(request).first else {
                fetchUserById(id, completion: completion)
                return
            }
            
            // user property must be accessed to trigger awakeFromFetch()
            _ = user.id
            
            let report = Report(ReportType.successfulCoreDataOperation(.fetch, resource: "User", isMultiple: false), owner: nil)
            log.debug(report)
            
            completion(user, nil)
        } catch {
            let report = Report(ReportType.failedCoreDataOperation(.fetch, resource: "User", isMultiple: false, error: error), owner: nil)
            log.error(report)
            
            fetchUserById(id, completion: completion)
        }
    }
    
}
