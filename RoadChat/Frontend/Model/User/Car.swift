//
//  Car.swift
//  RoadChat
//
//  Created by Niklas Sauer on 02.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import CoreData
import RoadChatKit
import UIKit

class Car: NSManagedObject {
    
    // MARK: - Public Class Methods
    class func createOrUpdate(from prototype: RoadChatKit.Car.PublicCar, in context: NSManagedObjectContext) throws -> Car {
        let request: NSFetchRequest<Car> = Car.fetchRequest()
        request.predicate = NSPredicate(format: "id = %d", prototype.id)
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count >= 1, "Car.create -- Database Inconsistency")
                
                // update existing car
                let car = matches.first!
                car.manufacturer = prototype.manufacturer
                car.model = prototype.model
                car.production = prototype.production
                
                // TODO: remove defaults for optionals
                car.performance = Int16(prototype.performance ?? 0)
                car.color = prototype.color
                
                return car
            }
        } catch {
            throw error
        }
        
        // create new car
        let car = Car(context: context)
        car.id = Int32(prototype.id)
        car.userID = Int32(prototype.userID)
        car.manufacturer = prototype.manufacturer
        car.model = prototype.model
        car.production = prototype.production
        
        // TODO: remove defaults for optionals
        car.performance = Int16(prototype.performance ?? 0)
        car.color = prototype.color
        
        return car
    }
    
    // MARK: - Public Properties
    var storedColor: UIColor? {
        guard let color = color else {
            return nil
        }
        
        return UIColor(hexString: color)
    }
    
}
