//
//  TrafficMessageCell.swift
//  RoadChat
//
//  Created by Phillip Rust on 05.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class TrafficMessageCell: UITableViewCell {

    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var upvotesLabel: UILabel!
    @IBOutlet weak var validationsLabel: UILabel!
    
    func configure(trafficMessage: TrafficMessage) {
        typeLabel.text = trafficMessage.type
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        timeLabel.text = dateFormatter.string(from: trafficMessage.time!)
        messageLabel.text = trafficMessage.message
        upvotesLabel.text = String(trafficMessage.upvotes)
        validationsLabel.text = String(trafficMessage.validations)
        
    }
   
    
}
