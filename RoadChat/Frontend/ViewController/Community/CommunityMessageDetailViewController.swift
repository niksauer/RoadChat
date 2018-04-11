//
//  CommunityMessageViewController.swift
//  RoadChat
//
//  Created by Malcolm Malam on 11.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class CommunityMessageDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var upvotesLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    private let viewFactory: ViewControllerFactory
    private let communityMessage: CommunityMessage
    private let user: User
    private let dateFormatter: DateFormatter

    init(viewFactory: ViewControllerFactory, message: CommunityMessage, user: User, dateFormatter: DateFormatter) {
        self.viewFactory = viewFactory
        self.communityMessage = message
        self.user = user
        self.dateFormatter = dateFormatter
        
        super.init(nibName: nil, bundle: nil)
        
        titleLabel.text = message.title
        messageLabel.text = message.message
        usernameLabel.text = "by \(user.username!)"
        upvotesLabel.text = String(message.upvotes)
        timeLabel.text = dateFormatter.string(from: message.time!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
