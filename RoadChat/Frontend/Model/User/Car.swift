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

class Car: NSManagedObject, ReportOwner {
    
    // MARK: - Public Types
    struct Copy: Equatable {
        let manufacturer: String
        let model: String
        let production: Date
        let performance: Int?
        let color: String?
    }
    
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
                
                car.performance = Int16(prototype.performance ?? -1)
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
        
        car.performance = Int16(prototype.performance ?? -1)
        car.color = prototype.color
        
        // update resources
        car.getImage(completion: nil)
        
        return car
    }
    
    // MARK: - Public Properties
    var storedColor: UIColor? {
        guard let color = color else {
            return nil
        }
        
        return UIColor(hexString: color)
    }
    
    var storedImage: UIImage? {
        guard let imageData = imageData else {
            return nil
        }
        
        return UIImage(data: imageData)
    }
    
    // MARK: - Private Properties
    private let carService = CarService(config: DependencyContainer().config)
    private let context = CoreDataStack.shared.viewContext
    
    // MARK: - ReportOwner Protocol
    var logDescription: String {
        return "'Car' [id: '\(self.id)']"
    }
    
    // MARK: - Initialization
    override func awakeFromFetch() {
        super.awakeFromFetch()
        get(completion: nil)
        getImage(completion: nil)
    }
    
    // MARK: - Public Methods
    func get(completion: ((Error?) -> Void)?) {
        carService.get(carID: Int(id)) { car, error in
            guard let car = car else {
                // pass service error
                let report = Report(.failedServerOperation(.retrieve, resource: nil, isMultiple: false, error: error!), owner: self)
                log.error(report)
                completion?(error!)
                return
            }
            
            do {
                _ = try Car.createOrUpdate(from: car, in: self.context)
                try self.context.save()
                let report = Report(.successfulCoreDataOperation(.retrieve, resource: nil, isMultiple: false), owner: self)
                log.debug(report)
                completion?(nil)
            } catch {
                let report = Report(.failedCoreDataOperation(.create, resource: nil, isMultiple: false, error: error), owner: self)
                log.error(report)
                completion?(error)
            }
        }
    }
    
    func save(completion: ((Error?) -> Void)?) {
        let carRequest = CarRequest(manufacturer: manufacturer!, model: model!, production: production!, performance: Int(performance), color: color)
        
        do {
            try carService.update(carID: Int(id), to: carRequest) { error in
                guard error == nil else {
                    let report = Report(.failedServerOperation(.update, resource: nil, isMultiple: false, error: error!), owner: self)
                    log.error(report)
                    completion?(error!)
                    return
                }
                
                do {
                    try self.context.save()
                    let report = Report(.successfulCoreDataOperation(.update, resource: nil, isMultiple: false), owner: self)
                    log.debug(report)
                    completion?(nil)
                } catch {
                    // pass core data error
                    let report = Report(.failedCoreDataOperation(.update, resource: nil, isMultiple: false, error: error), owner: self)
                    log.error(report)
                    completion?(error)
                }
            }
        } catch {
            // pass body encoding error
            let report = Report(.failedServerRequest(requestType: "CarRequest", error: error), owner: self)
            log.error(report)
            completion?(error)
        }
    }
    
    func delete(completion: ((Error?) -> Void)?) {
        carService.delete(carID: Int(id)) { error in
            guard error == nil else {
                let report = Report(.failedServerOperation(.delete, resource: nil, isMultiple: false, error: error!), owner: self)
                log.error(report)
                completion?(error!)
                return
            }
            
            do {
                self.context.delete(self)
                try self.context.save()
                let report = Report(.successfulCoreDataOperation(.delete, resource: nil, isMultiple: false), owner: self)
                log.debug(report)
                completion?(nil)
            } catch {
                let report = Report(.failedCoreDataOperation(.delete, resource: nil, isMultiple: false, error: error), owner: self)
                log.error(report)
                completion?(error)
            }
        }
    }

    func getImage(completion: ((Error?) -> Void)?) {
        carService.getImage(carID: Int(id)) { image, error in
            guard let image = image else {
                let report = Report(.failedServerOperation(.retrieve, resource: "Image", isMultiple: false, error: error!), owner: self)
                log.error(report)
                completion?(error!)
                return
            }
            
            do {
                self.imageData = image.data
                try self.context.save()
                let report = Report(.successfulCoreDataOperation(.retrieve, resource: "Image", isMultiple: false), owner: self)
                log.debug(report)
                completion?(nil)
            } catch {
                let report = Report(.failedCoreDataOperation(.update, resource: "Image", isMultiple: false, error: error), owner: self)
                log.error(report)
                completion?(error)
            }
        }
    }
    
    func uploadImage(_ image: UIImage, completion: ((Error?) -> Void)?) {
        carService.uploadImage(image, carID: Int(id)) { data, error in
            guard let data = data else {
                let report = Report(.failedServerOperation(.update, resource: "Image", isMultiple: false, error: error!), owner: self)
                log.error(report)
                completion?(error!)
                return
            }
            
            do {
                self.imageData = data
                try self.context.save()
                let report = Report(.successfulCoreDataOperation(.update, resource: "Image", isMultiple: false), owner: self)
                log.debug(report)
                completion?(nil)
            } catch {
                let report = Report(.failedCoreDataOperation(.update, resource: "Image", isMultiple: false, error: error), owner: self)
                log.error(report)
                completion?(error)
            }
        }
    }
    
}
