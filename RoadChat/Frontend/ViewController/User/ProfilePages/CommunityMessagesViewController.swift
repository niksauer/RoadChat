//
//  CommunityMessagesViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 05.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class CommunityMessagesViewController: UIViewController {

    // MARK: - Outlets
    
    // MARK: - Private Properties
    let messages: [CommunityMessage]?
    
    // MARK: - Initialization
    init(messages: [CommunityMessage]?) {
        self.messages = messages
        
        super.init(nibName: nil, bundle: nil)
        self.title = "Community"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

}
