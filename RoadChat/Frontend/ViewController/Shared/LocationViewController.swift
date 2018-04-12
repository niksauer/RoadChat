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
    
    private var locateUserButton: UIButton!
    
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
        
        // locate user button
        locateUserButton = UIButton(type: UIButtonType.custom)
        locateUserButton.addTarget(self, action: #selector(self.didPressLocateUserButton (_:)), for: UIControlEvents.touchUpOutside)
        locateUserButton.setImage(#imageLiteral(resourceName: "locate"), for: .normal)
        locateUserButton.backgroundColor = UIColor.white
        locateUserButton.backgroundColor?.withAlphaComponent(0.5)
        
//        var buttonFrame = locateUserButton.frame;
//        buttonFrame.size = CGSize(width: 20, height: 20);
//        locateUserButton.frame = buttonFrame
        
        
        
        view.addSubview(locateUserButton)
        locateUserButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            locateUserButton.heightAnchor.constraint(equalToConstant: 30),
            locateUserButton.widthAnchor.constraint(equalToConstant: 30),
            locateUserButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            locateUserButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100),
        ])
    }
    
    // MARK: - Private Methods
    @objc func didPressLocateUserButton(_ sender: Any) {
        mapView.showsUserLocation = true
        mapView.setCenter(mapView.userLocation.coordinate, animated: true)
        let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
        mapView.setRegion(region, animated: true)
    }

}
