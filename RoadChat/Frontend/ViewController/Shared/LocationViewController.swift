//
//  LocationViewController.swift
//  RoadChat
//
//  Created by Malcolm Malam on 11.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class LocationViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
   
    // MARK: - Views
    private var locateUserButton: UIButton!
    
    // MARK: - Private Properties
    private let viewFactory: ViewControllerFactory
    private let location: CLLocation
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, location: CLLocation){
        self.location = location
        self.viewFactory = viewFactory
    
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
    
        mapView.setCenter(location.coordinate, animated: true)
        mapView.addAnnotation(annotation)
    
        let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        mapView.setRegion(region, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        mapView.setCenter(location.coordinate, animated: true)
        mapView.showsUserLocation = true
    }
    
    // MARK: - Private Methods
    @IBAction func didPressLocateButton(_ sender: UIButton) {
        if mapView.userLocation.isAccessibilityElement == true {
        mapView.showsUserLocation = true
            
            let zoomRect: MKMapRect = MKMapRectNull
            let userLocationAnnotation = MKMapPointForCoordinate(mapView.userLocation.coordinate)
            let senderLocationAnnotation = MKMapPointForCoordinate(location.coordinate)
            let userLocationPoint: MKMapRect = MKMapRectMake(userLocationAnnotation.x, userLocationAnnotation.y, 0, 0)
            let senderLocationPoint: MKMapRect = MKMapRectMake(senderLocationAnnotationt.x, senderLocationAnnotation.y, 0, 0)
            
            zoomRect = MKMapRectUnion(userLocationPoint, senderLocationPoint)
            mapView.setVisibleMapRect(zoomRect, animated: true)
        
            /*let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
        mapView.setRegion(region, animated: true)
        mapView.setCenter(mapView.userLocation.coordinate, animated: true)*/
        } else {
            displayAlert(title: "Error", message: "Could not retrieve user location")
        }
        
    }
    
}
