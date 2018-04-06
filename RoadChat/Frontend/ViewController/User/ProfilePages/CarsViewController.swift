//
//  CarsViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 05.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class CarsViewController: UITableViewController {

    // MARK: - Outlets
    
    // MARK: - Private Properties
    private let cars: [Car]?
    private let dateFormatter: DateFormatter
    
    // MARK: - Initialization
    init(cars: [Car]?, dateFormatter: DateFormatter) {
        self.cars = cars
        self.dateFormatter = dateFormatter
        
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

    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let car = cars?[indexPath.row] else {
            fatalError()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CarCell", for: indexPath) as! CarCell
        cell.configure(car: car, dateFormatter: dateFormatter)
        
        return cell
    }
    
}

// MARK: - Table View Data Source
extension CarsViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cars?.count ?? 0
    }
}
