//
//  GroupedOptionTableViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 16.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class GroupedOptionTableViewController: UITableViewController, SwitchCellDelegate {

    // MARK: - Public Types
    class GroupedOption {
        var option: Option
        let section: Int
        let row: Int
        
        init(_ option: Option, section: Int, row: Int) {
            self.option = option
            self.section = section
            self.row = row
        }
    }
    
    // MARK: - Public Properties
    var options: [GroupedOption]
    var hasChangedOption = false
    
    // MARK: - Initialization
    init(options: [GroupedOption]) {
        self.options = options
        
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        tableView.register(UINib(nibName: "SwitchCell", bundle: nil), forCellReuseIdentifier: "SwitchCell")
    }

    // MARK: - Public Methods
    func groupedOption(for cell: SwitchCell) -> GroupedOption? {
        guard let indexPath = tableView.indexPath(for: cell), let groupedOption = options.first(where: { $0.section == indexPath.section && $0.row == indexPath.row }) else {
            return nil
        }
        
        return groupedOption
    }
    
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Set(options.map { $0.section}).count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.filter { $0.section == section }.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let option = options.first(where: { $0.section == indexPath.section && $0.row == indexPath.row })?.option else {
            fatalError()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
        cell.delegate = self
        cell.configure(text: option.name, isOn: option.isEnabled)
        
        return cell
    }
    
    // MARK: - Switch Cell Delegate
    func switchCellDidChangeState(_ sender: SwitchCell) {
        guard let indexPath = tableView.indexPath(for: sender), let groupedOption = options.first(where: { $0.section == indexPath.section && $0.row == indexPath.row }) else {
            return
        }
        
        groupedOption.option.isEnabled = sender.stateSwitch.isOn
        hasChangedOption = true
    }
    

}
