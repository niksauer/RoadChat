//
//  RadarViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 16.05.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import MapKit
import RoadChatKit
import CoreData

class RadarViewController: UIViewController, MKMapViewDelegate, LocationManagerDelegate {
    
    // MARK: - Views
    private let mapView = MKMapView()
    private var createBarButton: UIBarButtonItem!
    
    // MARK: - Private Properties
    private let viewFactory: ViewControllerFactory
    private let activeUser: User
    private let conversationManager: ConversationManager
    private let locationManager: LocationManager
    private let userManager: UserManager
    private let searchContext: NSManagedObjectContext
    
    private var setInitialUserLocation = false
    private var annotations = [NearbyUser]()
    private var selectedUser: NearbyUser?
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, activeUser: User, conversationManager: ConversationManager, locationManager: LocationManager, userManager: UserManager, searchContext: NSManagedObjectContext) {
        self.viewFactory = viewFactory
        self.activeUser = activeUser
        self.conversationManager = conversationManager
        self.locationManager = locationManager
        self.userManager = userManager
        self.searchContext = searchContext
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = "Nearby Users"
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
        guard let selectedUser = selectedUser?.user else {
            return
        }
        
        if let conversation = conversationManager.findConversationByParticipants([selectedUser], requestor: activeUser, context: searchContext) {
            let conversationController = self.viewFactory.makeConversationViewController(for: conversation, activeUser: activeUser)
            conversationController.isEntryActive = true
            self.navigationController?.pushViewController(conversationController, animated: true)
        } else {
            let request = ConversationRequest(title: nil, participants: [selectedUser.id])
            
            activeUser.createConversation(request) { conversation, error in
                guard let conversation = conversation else {
                    self.displayAlert(title: "Error", message: "Failed to create conversation: \(error!)") {
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                    return
                }
                
                let conversationController = self.viewFactory.makeConversationViewController(for: conversation, activeUser: self.activeUser)
                conversationController.isEntryActive = true
                self.navigationController?.pushViewController(conversationController, animated: true)
            }
        }
    }
    
    private func updateUI() {
        conversationManager.getNearbyUsers { users, error in
            guard let users = users else {
                self.displayAlert(title: "Error", message: "Failed to retrieve nearby users: \(error!)") {
                    self.dismiss(animated: true, completion: nil)
                }
                
                return
            }
            
            // add delta updates
            let newNearbyUsers = users.filter { newNearbyUser in
                !self.annotations.contains { existingAnnotation in
                    newNearbyUser.id == existingAnnotation.user.id
                }
            }
            
            let newAnnotations: [NearbyUser] = newNearbyUsers.compactMap {
                guard let location = $0.location else {
                    return nil
                }
                
                let coreLocation = CLLocation(location: location)
                let annotation = NearbyUser(user: $0, coordinate: coreLocation.coordinate)
                annotation.title = $0.username
                return annotation
            }
            
            self.annotations.append(contentsOf: newAnnotations)
            self.mapView.addAnnotations(newAnnotations)
            
            // remove delta updates
            let oldAnnotations: [NearbyUser] = self.annotations.filter { existingAnnotation in
                !users.contains { newNearbyUser in
                    existingAnnotation.user.id == newNearbyUser.id
                }
            }
            
            for oldAnnotation in oldAnnotations {
                guard let index = self.annotations.index(of: oldAnnotation) else {
                    continue
                }
                
                self.annotations.remove(at: index)
            }
            
            self.mapView.removeAnnotations(oldAnnotations)
        }
    }
    
    // MARK: - MKMapView Delegate
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let userLocation = userLocation.location, userLocation.horizontalAccuracy <= 500, !setInitialUserLocation else {
            return
        }
        
        mapView.centerCoordinate = userLocation.coordinate
        let region = MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        self.mapView.setRegion(region, animated: true)
        setInitialUserLocation = true
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let _ = annotation as? NearbyUser else {
            return nil
        }

        // return custom annotation view
        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "NearbyUser")
        pin.canShowCallout = true

        return pin
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let nearbyUser = view.annotation as? NearbyUser else {
            return
        }
        
        selectedUser = nearbyUser
        createBarButton.isEnabled = true
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        guard let _ = view.annotation as? NearbyUser else {
            return
        }
        
        selectedUser = nil
        createBarButton.isEnabled = false
    }
    
    // MARK: - LocationManager Delegate
    func didUpdateRemoteLocation() {
        updateUI()
    }

}

class NearbyUser: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    var title: String?
    let user: RoadChatKit.User.PublicUser
    
    init(user: RoadChatKit.User.PublicUser, coordinate: CLLocationCoordinate2D) {
        self.user = user
        self.coordinate = coordinate
    }
}

