//
//  CreateNewReusableView.swift
//  RoadChat
//
//  Created by Niklas Sauer on 16.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

protocol CreateNewCellDelegate {
    func didPressAddButton(_ sender: CreateNewCellView)
}

class CreateNewCellView: UICollectionReusableView {

    // MARK: - Typealiases
    typealias ColorPalette = BasicColorPalette

    // MARK: - Outlets
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var elementLabel: UILabel!
    
    // MARK: - Publc Properties
    var delegate: CreateNewCellDelegate?
    
    // MARK: - Public Methods
    func configure(text: String, colorPalette: ColorPalette) {
        elementLabel.text = text
        addButton.tintColor = colorPalette.createColor
    }
    
    @IBAction func didPressAddButton(_ sender: UIButton) {
        delegate?.didPressAddButton(self)
    }
    
}
