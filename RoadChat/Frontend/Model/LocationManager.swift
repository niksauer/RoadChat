//
//  LocationManager.swift
//  RoadChat
//
//  Created by Phillip Rust on 09.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    // MARK: - Public Properties
    var lastLocation: CLLocation?
    
    // MARK: - Private Properties
    private let locationManager = CLLocationManager()
    
    // MARK: - Initialization
    override init() {
        super.init()
        locationManager.delegate = self
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
    }

}
