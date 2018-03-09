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
    
    static let shared = CoreDataStack()
    private override init() {}
    
    // MARK: - Core Data Stack
    var viewContext: NSManagedObjectContext {
        let viewContext = persistentContainer.viewContext
//        viewContext.automaticallyMergesChangesFromParent = true
        return viewContext
    }
    
    var backgroundContext: NSManagedObjectContext {
        let backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = viewContext
        backgroundContext.automaticallyMergesChangesFromParent = true
        return backgroundContext
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
    
    // MARK: - Core Data Saving Support
    func saveViewContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
}
