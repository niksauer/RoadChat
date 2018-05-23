//
//  ParticipantCell.swift
//  RoadChat
//
//  Created by Niklas Sauer on 22.05.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class ParticipantCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var approvalStatusLabel: UILabel!
    
    // MARK: - Public Methods
    func configure(participant: Participant, isAwaitingRequest: Bool) {
        usernameLabel.text = participant.user?.username
        approvalStatusLabel.text = isAwaitingRequest ? "requested" : nil
        
        // profile image appearance
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
    }
    

}
