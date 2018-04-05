//
//  CarsViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 05.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class CarsViewController: UIViewController {

    // MARK: - Outlets
    
    // MARK: - Private Properties
    private let cars: [Car]?
    
    // MARK: - Initialization
    init(cars: [Car]?) {
        self.cars = cars
        
        super.init(nibName: nil, bundle: nil)
        self.title = "Cars"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
