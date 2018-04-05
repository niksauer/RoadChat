//
//  TrafficMessagesViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 05.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class TrafficMessagesViewController: UIViewController {

    // MARK: - Outlets
    
    // MARK: - Private Properties
    let messages: [TrafficMessage]?
    
    // MARK: - Initialization
    init(messages: [TrafficMessage]?) {
        self.messages = messages
        
        super.init(nibName: nil, bundle: nil)
        self.title = "Traffic"
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
