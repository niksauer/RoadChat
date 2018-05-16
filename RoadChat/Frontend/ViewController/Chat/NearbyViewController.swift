//
//  NearbyViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 16.05.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import MapKit
import RoadChatKit

class NearbyViewController: UIViewController, MKMapViewDelegate, LocationManagerDelegate {
    
    // MARK: - Views
    private let mapView = MKMapView()
    private var createBarButton: UIBarButtonItem!
    
    // MARK: - Private Properties
    private let activeUser: User
    private let conversationManager: ConversationManager
    private let locationManager: LocationManager
    
    private var setInitialUserLocation = false
    
    // MARK: - Initialization
    init(activeUser: User, conversationManager: ConversationManager, locationManager: LocationManager) {
        self.activeUser = activeUser
        self.conversationManager = conversationManager
        self.locationManager = locationManager
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = "Nearby"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed))
        createBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "create_new_glyph"), style: .plain, target: self, action: #selector(createButtonPressed))
        self.navigationItem.rightBarButtonItem = createBarButton
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(mapView)
        mapView.pin(to: view)
        
        createBarButton.isEnabled = false
        locationManager.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateUI()
    }
    
    // MARK: - Private Methods
    @objc private func cancelButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func createButtonPressed() {
        
    }
    
    private func updateUI() {
        conversationManager.getNearbyUsers { users, error in
            guard let users = users else {
                self.displayAlert(title: "Error", message: "Failed to retrieve nearby users: \(error!)") {
                    self.dismiss(animated: true, completion: nil)
                }
                
                return
            }
            
            var annotations = [MKAnnotation]()
            
            for user in users {
                guard let location = user.location else {
                    continue
                }
                
                let coreLocation = CLLocation(location: location)
                let annotation = MKPointAnnotation()
                annotation.coordinate = coreLocation.coordinate
                
                annotations.append(annotation)
            }
            
            self.mapView.addAnnotations(annotations)
            
            let userLocation = self.mapView.userLocation.coordinate
            let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    // MARK: - MKMapView Delegate
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let userLocation = userLocation.location, userLocation.horizontalAccuracy <= 500 else {
            return
        }
        
        if !setInitialUserLocation {
            mapView.centerCoordinate = userLocation.coordinate
            setInitialUserLocation = true
        }
    }
    
    // MARK: - LocationManager Delegate
    func didUpdateRemoteLocation() {
        updateUI()
    }

}
