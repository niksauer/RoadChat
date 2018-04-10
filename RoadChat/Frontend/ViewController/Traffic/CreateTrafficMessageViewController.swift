//
//  CreateTrafficMessageController.swift
//  RoadChat
//
//  Created by Phillip Rust on 07.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import RoadChatKit

class CreateTrafficMessageViewController: UIViewController {
    
    // MARK: - Outlets
    
    // Mark: - Private Properties
    private let trafficBoard: TrafficBoard
    private let locationManager: LocationManager
    
    // MARK: - Initialization
    init(trafficBoard: TrafficBoard, locationManager: LocationManager) {
        self.trafficBoard = trafficBoard
        self.locationManager = locationManager
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = "New Traffic Message"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed(_:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .done, target: self, action: #selector(sendButtonPressed(_:)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    @IBAction func sendButtonPressed(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

