//
//  CommunityMessageCell.swift
//  RoadChat
//
//  Created by Niklas Sauer on 09.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import RoadChatKit

protocol CommunityMessageCellDelegate: class {
    func communityMessageCellDidPressUpvote(_ sender: CommunityMessageCell)
    func communityMessageCellDidPressDownvote(_ sender: CommunityMessageCell)
}

class CommunityMessageCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var upvotesImage: UIImageView!
    @IBOutlet weak var upvotesLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var downvoteButton: UIButton!
    
    // MARK: - Public Properties
    weak var delegate: CommunityMessageCellDelegate?
    var colorPalette: KarmaColorPalette!
    
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
    
    // MARK: - Public Methods
    func configure(message: CommunityMessage, dateFormatter: DateFormatter) {
        titleLabel.text = message.title
        messageLabel.text = message.message
        
        timeLabel.text = dateFormatter.string(from: message.time!)
        upvotesLabel.text = String(message.upvotes)
        
        karma = message.storedKarma
    }
    
    func reset() {
        titleLabel.text = nil
        messageLabel.text = nil
        
        timeLabel.text = nil
        upvotesLabel.text = nil
        
        karma = .neutral
    }
    
    @IBAction func upvoteButtonPressed(_ sender: UIButton) {
        delegate?.communityMessageCellDidPressUpvote(self)
    }
    
    @IBAction func downvoteButtonPressed(_ sender: UIButton) {
        delegate?.communityMessageCellDidPressDownvote(self)
    }
    
    /// https://stackoverflow.com/questions/26143591/specifying-one-dimension-of-cells-in-uicollectionview-using-auto-layout
    func preferredLayoutSizeFittingWidth(_ width: CGFloat) -> CGSize {
        // save original frame and preferredMaxLayoutWidth
        let originalFrame = self.frame
        
        let originalTitleLabelPreferredMaxLayoutWidth = titleLabel.preferredMaxLayoutWidth
        let originalMessageLabelPreferredMaxLayoutWidth = messageLabel.preferredMaxLayoutWidth
        
        let originalTimeLabelPrefferedMaxLayoutWidth = timeLabel.preferredMaxLayoutWidth
        let originalUpvotesLabelPreferredMaxLayoutWidth = upvotesLabel.preferredMaxLayoutWidth
        
        // assert: targetSize.width has the required width of the cell
        
        // step1: set the cell.frame to use that width
        self.frame.size = CGSize(width: width, height: self.frame.height)
        
        // step2: layout the cell
        setNeedsLayout()
        layoutIfNeeded()
        
        titleLabel.preferredMaxLayoutWidth = titleLabel.bounds.size.width
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
        
        titleLabel.preferredMaxLayoutWidth = originalTitleLabelPreferredMaxLayoutWidth
        messageLabel.preferredMaxLayoutWidth = originalMessageLabelPreferredMaxLayoutWidth
        
        timeLabel.preferredMaxLayoutWidth = originalTimeLabelPrefferedMaxLayoutWidth
        upvotesLabel.preferredMaxLayoutWidth = originalUpvotesLabelPreferredMaxLayoutWidth
        
        // reset cell content
        reset()
        
        return newSize
    }

}
