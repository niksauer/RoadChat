//
//  DirectMessageCell.swift
//  RoadChat
//
//  Created by Niklas Sauer on 17.05.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class DirectMessageCell: UICollectionViewCell {

    // MARK: - Typealiases
//    typealias ColorPalette =
    
    // MARK: - Outlets
//    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    
    // MARK: - Public Methods
    func configure(message: DirectMessage, dateFormatter: DateFormatter) {
//        textView.text = message.message
        timeLabel.text = dateFormatter.string(from: message.time!)
    }

    func reset() {
//        textView.text = nil
        timeLabel.text = nil
    }
    
    /// https://stackoverflow.com/questions/26143591/specifying-one-dimension-of-cells-in-uicollectionview-using-auto-layout
    func preferredLayoutSizeFittingWidth(_ width: CGFloat) -> CGSize {
        // save original frame and preferredMaxLayoutWidth
        let originalFrame = self.frame
        
//        let originalTextViewPreferredMaxLayoutWidth = textView.preferredMaxLayoutWidth
        let originalTimeLabelPreferredMaxLayoutWidth = timeLabel.preferredMaxLayoutWidth
        
        // assert: targetSize.width has the required width of the cell
        
        // step1: set the cell.frame to use that width
        self.frame.size = CGSize(width: width, height: self.frame.height)
        
        // step2: layout the cell
        setNeedsLayout()
        layoutIfNeeded()
        
//        textView.preferredMaxLayoutWidth = messageLabel.bounds.size.width
        timeLabel.preferredMaxLayoutWidth = timeLabel.bounds.size.width
        
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
        
//        textView.preferredMaxLayoutWidth = originalTextViewPreferredMaxLayoutWidth
        timeLabel.preferredMaxLayoutWidth = originalTimeLabelPreferredMaxLayoutWidth
        
        // reset cell content
        reset()
        
        return newSize
    }
    
}
