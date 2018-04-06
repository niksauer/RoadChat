//
//  CarCell.swift
//  RoadChat
//
//  Created by Niklas Sauer on 06.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class CarCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var modelLabel: UILabel!
    
    @IBOutlet weak var performanceLabel: UILabel!
    @IBOutlet weak var productionLabel: UILabel!
    
    @IBOutlet weak var colorLabel: UILabel!
    
    // MARK: - Public Methods
    func configure(car: Car, dateFormatter: DateFormatter) {
        modelLabel.text = "\(car.manufacturer!) \(car.model!)"
        performanceLabel.text = String(car.performance)
        productionLabel.text = dateFormatter.string(from: car.production!)
        colorLabel.text = String(car.color)
    }
    
}
