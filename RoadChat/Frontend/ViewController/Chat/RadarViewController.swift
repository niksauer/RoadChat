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

class RadarViewController: UIViewController, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, LocationManagerDelegate {
    
    // MARK: - Private Types
    private class NearbyUserAnnotation: NSObject, MKAnnotation {
        let coordinate: CLLocationCoordinate2D
        var title: String?
        let user: RoadChatKit.User.PublicUser
        
        init(user: RoadChatKit.User.PublicUser, coordinate: CLLocationCoordinate2D) {
            self.user = user
            self.coordinate = coordinate
        }
    }
    
    private struct NearbyUser {
        let user: User
        let coordinate: CLLocationCoordinate2D
    }
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Views
    private var createBarButton: UIBarButtonItem!
    
    // MARK: - Private Properties
    private let viewFactory: ViewControllerFactory
    private let activeUser: User
    private let conversationManager: ConversationManager
    private let locationManager: LocationManager
    private let userManager: UserManager
    private let searchContext: NSManagedObjectContext
    private let lengthFormatter: LengthFormatter
    
    private var setInitialUserLocation = false
    private var annotations = [NearbyUserAnnotation]()
    private var selectedUsers = [NearbyUser]() {
        didSet {
            validateCreateBarButton()
            updateTableViewConstraints()
        }
    }
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, activeUser: User, conversationManager: ConversationManager, locationManager: LocationManager, userManager: UserManager, searchContext: NSManagedObjectContext, lengthFormatter: LengthFormatter) {
        self.viewFactory = viewFactory
        self.activeUser = activeUser
        self.conversationManager = conversationManager
        self.locationManager = locationManager
        self.userManager = userManager
        self.searchContext = searchContext
        self.lengthFormatter = lengthFormatter
        
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
        
        tableView.register(UINib(nibName: "ParticipantCell", bundle: nil), forCellReuseIdentifier: "ParticipantCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 15
        tableView.allowsSelection = false
        updateTableViewConstraints()
        
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
        func createConversation(_ request: ConversationRequest, creator: User) {
            creator.createConversation(request) { conversation, error in
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
        
        if selectedUsers.count >= 2 {
            displayInputDialog(title: "Group Chat", message: "Please enter a title for this conversation.", placeholder: "Title", onCancel: { _ in
                self.dismiss(animated: true, completion: nil)
            }) { text in
                let request = ConversationRequest(title: text, recipients: self.selectedUsers.map { Int($0.user.id) })
                createConversation(request, creator: self.activeUser)
            }
        } else {
            let request = ConversationRequest(title: nil, recipients: selectedUsers.map { Int($0.user.id) })
            createConversation(request, creator: activeUser)
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
            
            let newAnnotations: [NearbyUserAnnotation] = newNearbyUsers.compactMap {
                guard let location = $0.location else {
                    return nil
                }
                
                let coreLocation = CLLocation(location: location)
                let annotation = NearbyUserAnnotation(user: $0, coordinate: coreLocation.coordinate)
                annotation.title = $0.username
                return annotation
            }
            
            self.annotations.append(contentsOf: newAnnotations)
            self.mapView.addAnnotations(newAnnotations)
            
            // remove delta updates
            let oldAnnotations: [NearbyUserAnnotation] = self.annotations.filter { existingAnnotation in
                !users.contains { newNearbyUser in
                    existingAnnotation.user.id == newNearbyUser.id
                }
            }
            
            for oldAnnotation in oldAnnotations {
                guard let index = self.annotations.index(of: oldAnnotation) else {
                    continue
                }
                
                self.annotations.remove(at: index)
                
                if let selectedUserIndex = self.selectedUsers.index(where: { $0.user.id == oldAnnotation.user.id}) {
                    self.selectedUsers.remove(at: selectedUserIndex)
                }
            }
            
            self.mapView.removeAnnotations(oldAnnotations)
        }
    }
    
    private func validateCreateBarButton() {
        createBarButton.isEnabled = selectedUsers.count >= 1
    }
    
    private func updateTableViewConstraints() {
        guard selectedUsers.count >= 1 else {
            tableView.isHidden = true
            return
        }
        
        let cellHeight = 44
        let maxCellsToDisplay = 3
        let maxTableViewHeight = CGFloat(maxCellsToDisplay * cellHeight)
        
        tableView.isHidden = false
        tableViewHeightConstraint.constant = CGFloat(selectedUsers.count * 44)
        
        if tableViewHeightConstraint.constant > maxTableViewHeight {
            tableViewHeightConstraint.constant = maxTableViewHeight
            tableView.isScrollEnabled = true
        } else {
            tableView.isScrollEnabled = false
        }
    }
    
    // MARK: - MKMapView Delegate
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let userLocation = userLocation.location, userLocation.horizontalAccuracy <= 500, !setInitialUserLocation else {
            tableView.reloadData()
            return
        }
        
        mapView.centerCoordinate = userLocation.coordinate
        let region = MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        self.mapView.setRegion(region, animated: true)
        setInitialUserLocation = true
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let _ = annotation as? NearbyUserAnnotation else {
            return nil
        }

        // return custom annotation view
        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "NearbyUser")
        pin.canShowCallout = true

        return pin
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let nearbyUserAnnotation = view.annotation as? NearbyUserAnnotation else {
            return
        }
        
        guard !selectedUsers.contains(where: { Int($0.user.id) == nearbyUserAnnotation.user.id }) else {
            return
        }
        
        userManager.findUserById(nearbyUserAnnotation.user.id, context: searchContext) { user, error in
            guard let user = user else {
                // handle user lookup error
                return
            }
            
            let nearbyUser = NearbyUser(user: user, coordinate: nearbyUserAnnotation.coordinate)
            self.selectedUsers.append(nearbyUser)
            let indexPath = IndexPath(row: self.selectedUsers.count-1, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }
    
    // MARK: - TableView Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let nearbyUser = selectedUsers[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParticipantCell", for: indexPath) as! ParticipantCell
        cell.configure(user: nearbyUser.user)
        
        if let userLocation = mapView.userLocation.location {
            let nearbyUserLocation = CLLocation(latitude: nearbyUser.coordinate.latitude, longitude: nearbyUser.coordinate.longitude)
            let distanceToNearbyUser = userLocation.distance(from: nearbyUserLocation)
            cell.rightLabel.text = lengthFormatter.string(fromMeters: distanceToNearbyUser)
        }
    
        return cell
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let nearbyUser = selectedUsers.remove(at: indexPath.row)
            
            if let nearbyUserAnnotation = annotations.first(where: { $0.user.id == nearbyUser.user.id }) {
                mapView.deselectAnnotation(nearbyUserAnnotation, animated: true)
            }
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        default:
            break
        }
    }
    
    // MARK: - LocationManager Delegate
    func didUpdateRemoteLocation() {
        updateUI()
    }

}

