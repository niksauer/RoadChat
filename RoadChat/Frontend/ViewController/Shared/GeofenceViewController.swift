//
//  filteredLocationController.swift
//  RoadChat
//
//  Created by Malcolm Malam on 16.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import MapKit

protocol GeofenceViewControllerDelegate {
    func didUpdateRadius(_ sender: GeofenceViewController)
}

class GeofenceViewController: UIViewController, MKMapViewDelegate {

    // MARK: - Typealiases
    typealias ColorPalette = GeofenceColorPalette
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var radiusSlider: UISlider!
    
    @IBOutlet weak var minLabel: EdgeInsetLabel!
    @IBOutlet weak var maxLabel: EdgeInsetLabel!
    
    // MARK: - Private Properties
    private var geofence: MKCircle?
    private let colorPalette: ColorPalette
    private let lengthFormatter: LengthFormatter
    
    private let initualRadius: Double
    private var setInitialGeofence = false
    private let stepSize: Float = 5
    
    
    // MARK: - Public Properties
    var radius: Double
    let min: Double
    let max: Double
    let identifier: String
    
    var delegate: GeofenceViewControllerDelegate?
    
    // MARK: - Views
    private var saveBarButtonItem: UIBarButtonItem!
    
    // MARK: - Initialization
    init(radius: Double?, min: Double, max: Double, identifier: String, colorPalette: ColorPalette, lengthFormatter: LengthFormatter) {
        self.initualRadius = radius ?? 5000
        self.radius = self.initualRadius
        self.min = min
        self.max = max
        self.identifier = identifier
        self.colorPalette = colorPalette
        self.lengthFormatter = lengthFormatter
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = "Geofence"
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
        radiusSlider.value = Float(radius)
        radiusSlider.minimumValue = Float(min)
        radiusSlider.maximumValue = Float(max)
        radiusSlider.isContinuous = true
        
        minLabel.text = lengthFormatter.string(fromMeters: min)
        maxLabel.text = lengthFormatter.string(fromMeters: max)
        
        mapView.delegate = self
        mapView.showsUserLocation = true
    }
    
    // MARK: - Public Methods
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        delegate?.didUpdateRadius(self)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didChangeRadius(_ sender: UISlider) {
        let roundedValue = round(sender.value / stepSize) * stepSize
        sender.value = roundedValue
        radius = Double(roundedValue)
        
        if radius != initualRadius {
            saveBarButtonItem.isEnabled = true
        }
        
        if let lastGeofence = geofence {
            mapView.remove(lastGeofence)
        }

        let userLocation = mapView.userLocation.coordinate
        let newGeofence = MKCircle(center: userLocation, radius: radius)
        mapView.setVisibleMapRect(newGeofence.boundingMapRect, animated: true)
        mapView.add(newGeofence)
        geofence = newGeofence

        if !setInitialGeofence {
            setInitialGeofence = true
        }
    }
    
    // MARK: - MKMapView Delegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let circle = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: circle)
            circleRenderer.fillColor = colorPalette.geofenceBackgroundColor
            circleRenderer.lineWidth = 0.3
            return circleRenderer
        } else {
            return MKOverlayRenderer()
        }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let userLocation = userLocation.location else {
            return
        }

        if userLocation.horizontalAccuracy <= 500, !setInitialGeofence {
            let newGeofence = MKCircle(center: userLocation.coordinate, radius: 10000)
            mapView.setVisibleMapRect(newGeofence.boundingMapRect, animated: true)
            mapView.add(newGeofence)
            geofence = newGeofence
            setInitialGeofence = true
        }
    }
    
}
