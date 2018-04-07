//
//  TrafficMessageCell.swift
//  RoadChat
//
//  Created by Phillip Rust on 05.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

protocol CommunityMessageCellDelegate: class {
    func communityMessageCellDidPressUpvote(_ sender: CommunityMessageCell)
    func communityMessageCellDidPressDownvote(_ sender: CommunityMessageCell)
}

class CommunityMessageCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var upvotesLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var downvoteButton: UIButton!

    // MARK: - Public Properties
    weak var delegate: CommunityMessageCellDelegate?
    
    // MARK: - Private Propertues
    private var message: CommunityMessage!
    
    // MARK: - Public Methods
    func configure(message: CommunityMessage, dateFormatter: DateFormatter) {
        self.message = message
    
        titleLabel.text = message.title
        timeLabel.text = dateFormatter.string(from: message.time!)
        messageLabel.text = message.message
        upvotesLabel.text = String(message.upvotes)
    }

    @IBAction func upvoteButtonPressed(_ sender: UIButton) {
        delegate?.communityMessageCellDidPressUpvote(self)
    }
    
    @IBAction func downvoteButtonPressed(_ sender: UIButton) {
        delegate?.communityMessageCellDidPressDownvote(self)
    }
    
}
