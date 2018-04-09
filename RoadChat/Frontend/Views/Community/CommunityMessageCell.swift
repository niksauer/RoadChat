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
    private let upvoteBgColor = UIColor(displayP3Red: 236/255, green: 104/255, blue: 44/255, alpha: 1)
    private let upvoteTextColor = UIColor.white
    
    private let neutralBgColor = UIColor.clear
    private let neutralTextColor = UIColor.black
    
    private let downvoteBgColor = UIColor(displayP3Red: 86/255, green: 94/255, blue: 227/255, alpha: 1)
    private let downvoteTextColor = UIColor.white
    
    // MARK: - Public Properties
    weak var delegate: CommunityMessageCellDelegate?
    
    var karma: KarmaType! {
        didSet {
            switch karma {
            case .upvote:
                upvoteButton.backgroundColor = upvoteBgColor
                upvoteButton.tintColor = upvoteTextColor

                downvoteButton.backgroundColor = neutralBgColor
                downvoteButton.tintColor = neutralTextColor
            
                upvotesImage.image = UIImage(named: "up-arrow")
                upvotesImage.tintColor = upvoteBgColor
            case .neutral:
                upvoteButton.backgroundColor = neutralBgColor
                upvoteButton.tintColor = neutralTextColor

                downvoteButton.backgroundColor = neutralBgColor
                downvoteButton.tintColor = neutralTextColor

                upvotesImage.image = UIImage(named: "up-arrow")
                upvotesImage.tintColor = neutralTextColor
            case .downvote:
                upvoteButton.backgroundColor = neutralBgColor
                upvoteButton.tintColor = neutralTextColor

                downvoteButton.backgroundColor = downvoteBgColor
                downvoteButton.tintColor = downvoteTextColor

                upvotesImage.image = UIImage(named: "down-arrow")
                upvotesImage.tintColor = downvoteBgColor
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
