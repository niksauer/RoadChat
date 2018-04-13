//
//  CarDetailViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 13.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class CarDetailViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var carImageView: UIImageView!
    
    @IBOutlet weak var manufacturerLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var performanceLabel: UILabel!
    @IBOutlet weak var productionLabel: UILabel!
    
    // MARK: - Private Properties
    let car: Car
    let dateFormatter: DateFormatter
    
    // MARK: - Initialization
    init(car: Car, dateFormatter: DateFormatter) {
        self.car = car
        self.dateFormatter = dateFormatter
        
        super.init(nibName: nil, bundle: nil)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didPressEditButton(_:)))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didPressDoneButton(_:)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        super.viewDidLoad()

        manufacturerLabel.text = car.manufacturer
        modelLabel.text = car.model
        
        usernameLabel.text = car.user?.username
        
        performanceLabel.text = "\(car.performance) HP"
        productionLabel.text = dateFormatter.string(from: car.production!)
    }
    
    // MARK: - Private Methods
    @objc func didPressEditButton(_ sender: UIBarButtonItem) {
        
    }
    
    @objc func didPressDoneButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

}
