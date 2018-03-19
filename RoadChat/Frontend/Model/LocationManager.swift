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
    let locationManager = CLLocationManager()
    var lastLocation: CLLocation?
    
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
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
    }

}
