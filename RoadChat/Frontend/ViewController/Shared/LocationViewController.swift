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

    // MARK: - Private Properties
    private let location: CLLocation
    private let viewFactory: ViewControllerFactory
    private var mapView: MKMapView!
    private var tapped: Bool = false
    
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
        let tap = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        tap.delegate = self
        myView.addGestureRecognizer(tap)
        
        self.mapView = MKMapView(frame: view.frame)
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
    
        mapView.setCenter(location.coordinate, animated: true)
        mapView.addAnnotation(annotation)
        
        let mapRegion: MKCoordinateRegion
        mapRegion.center = mapView.center
        mapRegion.span.latitudeDelta = 0.2
        mapRegion.span.longitudeDelta = 0.2
        
        mapView.setRegion(mapRegion, animated: true)
    }
    
   /* func handleTap(sender: UITapGestureRecognizer? = nil) {
        if (!tapped) {
        self.mapView.frame = self.view.bounds
        } else {
            
        }
    } */

}
