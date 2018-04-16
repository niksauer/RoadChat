//
//  filteredLocationController.swift
//  RoadChat
//
//  Created by Malcolm Malam on 16.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import MapKit

class filteredLocationController: UIViewController, MKMapViewDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var filterLocationSlider: UISlider!
    
    // MARK: - Private Properties
    private var radius: Double
    private var filterCircle: MKCircle
    
    // MARK: - Views
    private var saveBarButtonItem: UIBarButtonItem!
    
    // MARK: - Initialization
    init(radius: Double?) {
        self.radius = radius ?? 10
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = "Adjust Filter"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed(_:)))
        self.saveBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButtonPressed(_:)))
        self.saveBarButtonItem.isEnabled = false
        self.navigationItem.rightBarButtonItem = saveBarButtonItem
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        filterLocationSlider.value = radius
        
        let userLocation = mapView.userLocation.coordinate
        mapView.setCenter(userLocation, animated: true)
        let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
        
        filterCircle = MKCircle(center: userLocation, radius: radius)
        mapView.add(filterCircle)

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Private Methods
    @IBAction func didChangeFilterValue(_ sender: UISlider) {
        filterCircle.radius = sender.value
        
        mapView.setVisibleMapRect(filterCircle.boundingMapRect, animated: true)
    }
    
    // MARK: - Public Methods
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
    //TODO
    }

}
