//
//  LocationManager.swift
//  RoadChat
//
//  Created by Phillip Rust on 09.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegate {
    func didUpdateLocation(to location: CLLocation?)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    // MARK: - Singleton
    static let shared = LocationManager()
    
    // MARK: - Public Properties
    var lastLocation: CLLocation?
    var distanceFilter: CLLocationDistance = 200
    var delegate: LocationManagerDelegate?
    
    // MARK: - Private Properties
    private let locationManager = CLLocationManager()
    
    // MARK: - Initialization
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.distanceFilter = distanceFilter
    }

    // MARK: - Public Methods
    func startPolling() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func stopPolling() {
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate Protocol
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
        delegate?.didUpdateLocation(to: lastLocation)
    }
    
}
