//
//  TrafficMessageCell.swift
//  RoadChat
//
//  Created by Phillip Rust on 05.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import RoadChatKit

protocol CommunityMessageCellDelegate: class {
    func communityMessageCellDidPressUpvote(_ sender: CommunityMessageCell)
    func communityMessageCellDidPressDownvote(_ sender: CommunityMessageCell)
}

class CommunityMessageCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var upvotesImage: UIImageView!
    @IBOutlet weak var upvotesLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var downvoteButton: UIButton!

    // MARK: - Private Properties
    private let upvoteColor = UIColor(displayP3Red: 236/255, green: 104/255, blue: 44/255, alpha: 1)
    private let downvoteColor = UIColor(displayP3Red: 86/255, green: 94/255, blue: 227/255, alpha: 1)
    
    // MARK: - Public Properties
    weak var delegate: CommunityMessageCellDelegate?
    
    var karma: KarmaType! {
        didSet {
            switch karma {
            case .upvote:
                upvoteButton.backgroundColor = upvoteColor
                upvoteButton.imageView?.tintColor = UIColor.white
                
                downvoteButton.backgroundColor = UIColor.clear
                downvoteButton.imageView?.tintColor = UIColor.black
            
                upvotesImage.image = #imageLiteral(resourceName: "up-arrow")
                upvotesImage.tintColor = upvoteColor
            case .neutral:
                upvoteButton.backgroundColor = UIColor.clear
                downvoteButton.imageView?.tintColor = UIColor.black
                
                downvoteButton.backgroundColor = UIColor.clear
                downvoteButton.imageView?.tintColor = UIColor.black
            
                upvotesImage.image = #imageLiteral(resourceName: "up-arrow")
                upvotesImage.tintColor = UIColor.black
            case .downvote:
                upvoteButton.backgroundColor = UIColor.clear
                upvoteButton.imageView?.tintColor = UIColor.black
                
                downvoteButton.backgroundColor = downvoteColor
                downvoteButton.imageView?.tintColor = UIColor.white
            
                upvotesImage.image = #imageLiteral(resourceName: "down-arrow")
                upvotesImage.tintColor = downvoteColor
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

    @IBAction func upvoteButtonPressed(_ sender: UIButton) {
        delegate?.communityMessageCellDidPressUpvote(self)
    }
    
    @IBAction func downvoteButtonPressed(_ sender: UIButton) {
        delegate?.communityMessageCellDidPressDownvote(self)
    }
    
}
