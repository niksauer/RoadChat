//
//  TextFieldCell.swift
//  RoadChat
//
//  Created by Niklas Sauer on 18.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class TextFieldCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var textFieldLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    // MARK: - Private Properties
    private var onChange: ((UITextField) -> Void)!
    
    // MARK: - Public Methods
    func configure(text: String, onChange: @escaping (UITextField) -> Void) {
        textFieldLabel.text = text
        self.onChange = onChange
    }

    @IBAction func edititingChanged(_ sender: UITextField) {
        onChange(sender)
    }
    
}
