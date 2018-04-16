//
//  CarCollectionCell.swift
//  RoadChat
//
//  Created by Niklas Sauer on 13.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class CarCell: UICollectionViewCell {

    // MARK: - Outlets
    @IBOutlet weak var manufacturerLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var performanceLabel: UILabel!
    @IBOutlet weak var productionLabel: UILabel!
    @IBOutlet weak var colorIndicator: UIView!
    
    // MARK: - Public Methods
    func configure(car: Car, dateFormatter: DateFormatter) {
        manufacturerLabel.text = car.manufacturer!
        modelLabel.text = car.model
        performanceLabel.text = "\(car.performance) HP"
        productionLabel.text = dateFormatter.string(from: car.production!)
        
        colorIndicator.layer.cornerRadius = colorIndicator.frame.size.width / 2
        colorIndicator.clipsToBounds = true
        colorIndicator.backgroundColor = car.storedColor
    }
    
    func reset() {
        modelLabel.text = nil
        
        performanceLabel.text = nil
        productionLabel.text = nil
    }
    
    /// https://stackoverflow.com/questions/26143591/specifying-one-dimension-of-cells-in-uicollectionview-using-auto-layout
    func preferredLayoutSizeFittingWidth(_ width: CGFloat) -> CGSize {
        // save original frame and preferredMaxLayoutWidth
        let originalFrame = self.frame
        
        let originalModelLabelPreferredMaxLayoutWidth = modelLabel.preferredMaxLayoutWidth
        
        let originalPerformanceLabelPrefferedMaxLayoutWidth = performanceLabel.preferredMaxLayoutWidth
        let originalProductionLabelPreferredMaxLayoutWidth = productionLabel.preferredMaxLayoutWidth
        
        // assert: targetSize.width has the required width of the cell
        
        // step1: set the cell.frame to use that width
        self.frame.size = CGSize(width: width, height: self.frame.height)
        
        // step2: layout the cell
        setNeedsLayout()
        layoutIfNeeded()
        
        modelLabel.preferredMaxLayoutWidth = modelLabel.bounds.size.width
        
        performanceLabel.preferredMaxLayoutWidth = performanceLabel.bounds.size.width
        productionLabel.preferredMaxLayoutWidth = productionLabel.bounds.size.width
        
        // assert: the label's bounds and preferredMaxLayoutWidth are set to the width required by the cell's width
        
        // step3: compute how tall the cell needs to be
        // this causes the cell to compute the height it needs, which it does by asking the
        // label what height it needs to wrap within its current bounds (which we just set).
        let computedSize = self.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        
        // assert: computedSize has the needed height for the cell
        
        // Apple: "Only consider the height for cells, because the contentView isn't anchored correctly sometimes."
        let newSize = CGSize(width: width, height: computedSize.height)
        
        // restore old frame and preferredMaxLayoutWidth
        self.frame = originalFrame
        
        modelLabel.preferredMaxLayoutWidth = originalModelLabelPreferredMaxLayoutWidth
        
        performanceLabel.preferredMaxLayoutWidth = originalPerformanceLabelPrefferedMaxLayoutWidth
        productionLabel.preferredMaxLayoutWidth = originalProductionLabelPreferredMaxLayoutWidth
        
        // reset cell content
        reset()
        
        return newSize
    }

    
}
