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
    
    //MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Private Properties
    private let location: CLLocation
    private let viewFactory: ViewControllerFactory
    //private var mapView: MKMapView!
    private var tapped: Bool = false
    
     private let userLocationButton: UIButton!
    
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
    
    @IBAction func didPressLocateButton(_ sender: UIButton) {
        print("zoom zoom")
        mapView.showsUserLocation = true
        let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
        mapView.setRegion(region, animated: true)
        mapView.setCenter(mapView.userLocation.coordinate, animated: true)
        
    }
    
    

}
