//
//  TrafficMessageCell.swift
//  RoadChat
//
//  Created by Phillip Rust on 05.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import RoadChatKit

protocol TrafficMessageCellDelegate: class {
    func trafficMessageCellDidPressUpvote(_ sender: TrafficMessageCell)
    func trafficMessageCellDidPressDownvote(_ sender: TrafficMessageCell)
}

class TrafficMessageCell: UICollectionViewCell {
    
    // MARK: - Typealiases
    typealias ColorPalette = KarmaColorPalette & TrafficColorPalette
    
    // MARK: - Outlets
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var upvotesImage: UIImageView!
    @IBOutlet weak var upvotesLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var downvoteButton: UIButton!
    
    @IBOutlet weak var typeIndicator: UIView!
    
    // MARK: - Public Properties
    weak var delegate: TrafficMessageCellDelegate?
    var colorPalette: ColorPalette!
    
    var karma: KarmaType! {
        didSet {
            switch karma {
            case .upvote:
                upvoteButton.backgroundColor = colorPalette.upvoteBgColor
                upvoteButton.tintColor = colorPalette.upvoteTextColor
                
                downvoteButton.backgroundColor = colorPalette.neutralBgColor
                downvoteButton.tintColor = colorPalette.neutralTextColor
                
                upvotesImage.image = UIImage(named: "up-arrow")
                upvotesImage.tintColor = colorPalette.upvoteBgColor
            case .neutral:
                upvoteButton.backgroundColor = colorPalette.neutralBgColor
                upvoteButton.tintColor = colorPalette.neutralTextColor
                
                downvoteButton.backgroundColor = colorPalette.neutralBgColor
                downvoteButton.tintColor = colorPalette.neutralTextColor
                
                upvotesImage.image = UIImage(named: "up-arrow")
                upvotesImage.tintColor = colorPalette.neutralTextColor
            case .downvote:
                upvoteButton.backgroundColor = colorPalette.neutralBgColor
                upvoteButton.tintColor = colorPalette.neutralTextColor
                
                downvoteButton.backgroundColor = colorPalette.downvoteBgColor
                downvoteButton.tintColor = colorPalette.downvoteTextColor
                
                upvotesImage.image = UIImage(named: "down-arrow")
                upvotesImage.tintColor = colorPalette.downvoteBgColor
            default:
                break
            }
        }
    }
    
    var type: TrafficType! {
        didSet {
            switch type {
            case .jam:
                typeIndicator.backgroundColor = colorPalette.jamBgColor
            case .accident:
                typeIndicator.backgroundColor = colorPalette.accidentBgColor
            case .danger:
                typeIndicator.backgroundColor = colorPalette.dangerBgColor
            case .detour:
                typeIndicator.backgroundColor = colorPalette.detourBgColor
            default:
                break
            }
        }
    }
    
    // MARK: - Public Methods
    func configure(message: TrafficMessage, dateFormatter: DateFormatter, colorPalette: ColorPalette) {
        self.colorPalette = colorPalette
        
        typeLabel.text = message.type
        messageLabel.text = message.message
        
        timeLabel.text = dateFormatter.string(from: message.time!)
        upvotesLabel.text = String(message.upvotes)
        
        karma = message.storedKarma
        type = message.storedType
    }
    
    func reset() {
        typeLabel.text = nil
        messageLabel.text = nil
        
        timeLabel.text = nil
        upvotesLabel.text = nil
        
        karma = .neutral
    }
    
    @IBAction func upvoteButtonPressed(_ sender: UIButton) {
        delegate?.trafficMessageCellDidPressUpvote(self)
    }
    
    @IBAction func downvoteButtonPressed(_ sender: UIButton) {
        delegate?.trafficMessageCellDidPressDownvote(self)
    }
    
    /// https://stackoverflow.com/questions/26143591/specifying-one-dimension-of-cells-in-uicollectionview-using-auto-layout
    func preferredLayoutSizeFittingWidth(_ width: CGFloat) -> CGSize {
        // save original frame and preferredMaxLayoutWidth
        let originalFrame = self.frame
        
        let originalTitleLabelPreferredMaxLayoutWidth = typeLabel.preferredMaxLayoutWidth
        let originalMessageLabelPreferredMaxLayoutWidth = messageLabel.preferredMaxLayoutWidth
        
        let originalTimeLabelPrefferedMaxLayoutWidth = timeLabel.preferredMaxLayoutWidth
        let originalUpvotesLabelPreferredMaxLayoutWidth = upvotesLabel.preferredMaxLayoutWidth
        
        // assert: targetSize.width has the required width of the cell
        
        // step1: set the cell.frame to use that width
        self.frame.size = CGSize(width: width, height: self.frame.height)
        
        // step2: layout the cell
        setNeedsLayout()
        layoutIfNeeded()
        
        typeLabel.preferredMaxLayoutWidth = typeLabel.bounds.size.width
        messageLabel.preferredMaxLayoutWidth = messageLabel.bounds.size.width
        
        timeLabel.preferredMaxLayoutWidth = timeLabel.bounds.size.width
        upvotesLabel.preferredMaxLayoutWidth = upvotesLabel.bounds.size.width
        
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
        
        typeLabel.preferredMaxLayoutWidth = originalTitleLabelPreferredMaxLayoutWidth
        messageLabel.preferredMaxLayoutWidth = originalMessageLabelPreferredMaxLayoutWidth
        
        timeLabel.preferredMaxLayoutWidth = originalTimeLabelPrefferedMaxLayoutWidth
        upvotesLabel.preferredMaxLayoutWidth = originalUpvotesLabelPreferredMaxLayoutWidth
        
        // reset cell content
        reset()
        
        return newSize
    }
    
}
