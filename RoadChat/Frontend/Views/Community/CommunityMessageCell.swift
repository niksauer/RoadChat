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
    
    // MARK: - Private Properties
    private var widthConstraint: NSLayoutConstraint?
    
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
    
    // MARK: - Initialization
//    override func awakeFromNib() {
//        super.awakeFromNib()
//    
//        self.contentView.translatesAutoresizingMaskIntoConstraints = false
//        widthConstraint = contentView.widthAnchor.constraint(equalToConstant: 0)
//    }
    
    // MARK: - Public Methods
    func configure(message: CommunityMessage, dateFormatter: DateFormatter) {
        titleLabel.text = message.title
        messageLabel.text = message.message
        
        timeLabel.text = dateFormatter.string(from: message.time!)
        upvotesLabel.text = String(message.upvotes)
        
        karma = message.storedKarma
    }

//    func setWidth(_ width: CGFloat) {
//        widthConstraint?.constant = width
//        widthConstraint?.isActive = true
//    }
    
    @IBAction func upvoteButtonPressed(_ sender: UIButton) {
        delegate?.communityMessageCellDidPressUpvote(self)
    }
    
    @IBAction func downvoteButtonPressed(_ sender: UIButton) {
        delegate?.communityMessageCellDidPressDownvote(self)
    }

}
