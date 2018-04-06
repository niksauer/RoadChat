//
//  ConversationCell.swift
//  RoadChat
//
//  Created by Niklas Sauer on 22.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class ConversationCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lastChangeLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    
    // MARK: - Public Methods
    func configure(conversation: Conversation, newestMessage: DirectMessage?) {
        titleLabel.text = conversation.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        lastChangeLabel.text = dateFormatter.string(from: conversation.lastChange!)
        
        lastMessageLabel.text = newestMessage?.message ?? "No messages..."
    }

}
