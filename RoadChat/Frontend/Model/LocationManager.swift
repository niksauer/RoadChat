//
//  LocationManager.swift
//  RoadChat
//
//  Created by Phillip Rust on 09.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import CoreLocation
import RoadChatKit

protocol LocationManagerDelegate {
    func didUpdateRemoteLocation()
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    // MARK: - Singleton
    static let shared = LocationManager()
    
    // MARK: - Public Properties
    var lastLocation: CLLocation?
    var distanceFilter: CLLocationDistance = 200
    var delegate: LocationManagerDelegate?
    var managedUser: User?
    
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
    
    // MARK: - Private Methods
    private func updateRemoteLocation() {
        guard let location = lastLocation, location.horizontalAccuracy <= distanceFilter, let user = managedUser, user.privacy!.shareLocation else {
            return
        }
        
        let locationRequest = LocationRequest(coreLocation: location)
        
        user.updateLocation(to: locationRequest) { error in
            guard error == nil else {
                return
            }
            
            self.delegate?.didUpdateRemoteLocation()
        }
    }
    
    // MARK: - CLLocationManagerDelegate Protocol
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
        updateRemoteLocation()
    }

}
