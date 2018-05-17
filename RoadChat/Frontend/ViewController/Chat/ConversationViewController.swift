//
//  ConversationViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 16.05.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class ConversationViewController: UIViewController {

    // MARK: - Private Properties
    private let viewFactory: ViewControllerFactory
    private let activeUser: User
    private let recipient: User
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, activeUser: User, recipient: User) {
        self.viewFactory = viewFactory
        self.activeUser = activeUser
        self.recipient = recipient
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = recipient.username
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "profile_glyph"), style: .plain, target: self, action: #selector(didPressProfileButton))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Private Methods
    @objc private func didPressProfileButton() {
        let profileViewController = viewFactory.makeProfileViewController(for: recipient, activeUser: activeUser)
        navigationController?.pushViewController(profileViewController, animated: true)
    }

}
