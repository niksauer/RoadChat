//
//  Privacy.swift
//  RoadChat
//
//  Created by Niklas Sauer on 02.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import CoreData
import RoadChatKit

struct Option {
    let name: String
    var isEnabled: Bool
}

class Privacy: NSManagedObject, ReportOwner {
    
    // MARK: - Public Class Methods
    class func createOrUpdate(from prototype: RoadChatKit.Privacy.PublicPrivacy, userID: Int, in context: NSManagedObjectContext) throws -> Privacy {
        let request: NSFetchRequest<Privacy> = Privacy.fetchRequest()
        request.predicate = NSPredicate(format: "user.id = %d", userID)
        
        do {
            let matches = try context.fetch(request)
            
            if matches.count > 0 {
                assert(matches.count >= 1, "Privacy.createOrUpdate -- Database Inconsistency")
                
                // update existing privacy
                let privacy = matches.first!
                privacy.shareLocation = prototype.shareLocation
                privacy.showEmail = prototype.showEmail
                privacy.showFirstName = prototype.showFirstName
                privacy.showLastName = prototype.showLastName
                privacy.showBirth = prototype.showBirth
                privacy.showSex = prototype.showSex
                privacy.showBiography = prototype.showBiography
                privacy.showStreet = prototype.showStreet
                privacy.showCity = prototype.showCity
                privacy.showCountry = prototype.showCountry
                
                return privacy
            }
        } catch {
            throw error
        }
        
        // create new privacy
        let privacy = Privacy(context: context)
        privacy.shareLocation = prototype.shareLocation
        privacy.showEmail = prototype.showEmail
        privacy.showFirstName = prototype.showFirstName
        privacy.showLastName = prototype.showLastName
        privacy.showBirth = prototype.showBirth
        privacy.showSex = prototype.showSex
        privacy.showBiography = prototype.showBiography
        privacy.showStreet = prototype.showStreet
        privacy.showCity = prototype.showCity
        privacy.showCountry = prototype.showCountry
        
        return privacy
    }
    
    // MARK: - Private Properties
    private let userService = UserService(config: DependencyContainer().config)
    private let context = CoreDataStack.shared.viewContext
    
    private var stateForOption: [String: Bool] {
        return [
            "Location":     shareLocation,
            "Email":        showEmail,
            "First Name":   showFirstName,
            "Last Name":    showLastName,
            "Birth":        showBirth,
            "Sex":          showSex,
            "Biography":    showBiography,
            "Street":       showStreet,
            "City":         showCity,
            "Country":      showCountry
        ]
    }
    
    // MARK: - Public Properties
    var options: [Option] {
        get {
            return stateForOption.map { Option(name: $0.key, isEnabled: stateForOption[$0.key]!) }
        }
        
        set {
            for option in newValue {
                switch option.name {
                case "Location":
                    shareLocation = option.isEnabled
                case "Email":
                    showEmail = option.isEnabled
                case "First Name":
                    showFirstName = option.isEnabled
                case "Last Name":
                    showLastName = option.isEnabled
                case "Birth":
                    showBirth = option.isEnabled
                case "Sex":
                    showSex = option.isEnabled
                case "Biography":
                    showBiography = option.isEnabled
                case "Street":
                    showStreet = option.isEnabled
                case "City":
                    showCity = option.isEnabled
                case "Country":
                    showCountry = option.isEnabled
                default:
                    break
                }
            }
        }
    }
    
    // MARK: - ReportOwner Protocol
    var logDescription: String {
        return "'Privacy' [userId: '\(self.user!.id)']"
    }
    
    // MARK: - Public Methods
    func save(completion: @escaping (Error?) -> Void) {
        do {
            let request = PrivacyRequest(shareLocation: shareLocation, showEmail: showEmail, showFirstName: showFirstName, showLastName: showLastName, showBirth: showBirth, showSex: showSex, showBiography: showBiography, showStreet: showStreet, showCity: showCity, showCountry: showCountry)
            
            try userService.updatePrivacy(userID: Int(self.user!.id), to: request) { error in
                guard error == nil else {
                    // pass service error
                    let report = Report(.failedServerOperation(.update, resource: "Privacy", isMultiple: false, error: error!), owner: self)
                    log.error(report)
                    completion(error!)
                    return
                }
                
                do {
                    try self.context.save()
                    let report = Report(.successfulCoreDataOperation(.update, resource: "Privacy", isMultiple: false), owner: self)
                    log.debug(report)
                    completion(nil)
                } catch {
                    // pass core data error
                    let report = Report(.failedCoreDataOperation(.update, resource: "Profile", isMultiple: false, error: error), owner: self)
                    log.error(report)
                    completion(error)
                }
            }
        } catch {
            // pass body encoding error
            let report = Report(.failedServerRequest(requestType: "PrivacyRequest", error: error), owner: self)
            log.error(report)
            completion(error)
        }
    }
    
}
