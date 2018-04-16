//
//  SwitchCell.swift
//  RoadChat
//
//  Created by Niklas Sauer on 15.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

protocol SwitchCellDelegate: class {
    func switchCellDidChangeState(_ sender: SwitchCell)
}

class SwitchCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var stateSwitch: UISwitch!
    
    // MARK: - Public Properties
    var delegate: SwitchCellDelegate?
    
    // MARK: - Public Methods
    func configure(text: String, isOn: Bool) {
        switchLabel.text = text
        stateSwitch.setOn(isOn, animated: false)
    }
    
    @IBAction func didChangeState(_ sender: UISwitch) {
        delegate?.switchCellDidChangeState(self)
    }
    
}
