//
//  TrafficMessageCell.swift
//  RoadChat
//
//  Created by Phillip Rust on 05.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class TrafficMessageCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var upvotesLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    // MARK: - Private Properties
    private var message: TrafficMessage!
    
    // MARK: - Public Methods
    func configure(message: TrafficMessage, dateFormatter: DateFormatter) {
        self.message = message

        timeLabel.text = dateFormatter.string(from: message.time!)
        messageLabel.text = message.message
        upvotesLabel.text = String(message.upvotes)
    }

    @IBAction func upvoteButtonPressed(_ sender: UIButton) {
//        message.upvote()
    }
    
    @IBAction func downvoteButtonPressed(_ sender: UIButton) {
//        message.downvote()
    }
    
}
