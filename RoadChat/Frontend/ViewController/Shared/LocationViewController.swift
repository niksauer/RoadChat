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
        userLocationButton = UIButton(type: UIButtonType.custom)
        userLocationButton.addTarget(self, action: #selector(self.zoomToUserLocation (_:)), for: UIControlEvents.touchUpOutside)
        userLocationButton.image(for: UIControlState.normal) = #imageLiteral(resourceName: "locate")
        var buttonFrame = button.frame;
        buttonFrame.size = CGSizeMake(20, 20);
        userLocationButton.frame = buttonFrame
        NSLayoutConstraint.activate([
            //userLocationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            userLocationButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            userLocationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 8),
            //userLocationButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        
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
    
        let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        mapView.setRegion(region, animated: true)
    }
    
    // MARK: - Private Methods
    @objc func zoomToUserLocation(_ sender: Any) {
        mapView.showsUserLocation = true
        mapView.setCenter(mapView.userLocation.coordinate, animated: true)
        let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
        mapView.setRegion(region, animated: true)
    }
    

}
