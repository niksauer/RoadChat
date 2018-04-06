//
//  CommunityMessageCell.swift
//  RoadChat
//
//  Created by Malcolm Malam on 05.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class CommunityMessageCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    func configure(communityMessage: CommunityMessage) { //<-- HERE
        titleLabel.text = communityMessage.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        lastChangeLabel.text = dateFormatter.string(from: conversation.lastChange!)
        
        lastMessageLabel.text = newestMessage?.message ?? "No messages..."
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func upvoteButtonPressed(_ sender: Any) {
    }
    
    @IBAction func downvoteButtonPressed(_ sender: Any) {
    }
}
