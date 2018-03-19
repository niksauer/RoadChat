//
//  CoreDataStack.swift
//  RoadChat
//
//  Created by Niklas Sauer on 08.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import CoreData

class CoreDataStack: NSObject {
    
    // MARK: - Singleton
    static let shared = CoreDataStack()
    
    // MARK: - Initialization
    private override init() {}
    
    // MARK: - Public Properties
    var viewContext: NSManagedObjectContext {
        let viewContext = persistentContainer.viewContext
        return viewContext
    }
        
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "RoadChat")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let nsError = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Public Methods
    func saveViewContext () {
        let context = viewContext
        
        if context.hasChanges {
            do {
                try context.save()
//                log.debug("Successfully saved changes to Core Data.")
            } catch {
                let nsError = error as NSError
                log.error("Failed to save view context: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
}
