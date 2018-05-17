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
    private let conversation: Conversation
    private let activeUser: User
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, conversation: Conversation, activeUser: User) {
        self.viewFactory = viewFactory
        self.conversation = conversation
        self.activeUser = activeUser
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = conversation.title
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "profile_glyph"), style: .plain, target: self, action: #selector(didPressProfileButton))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        super.viewDidLoad()

        let directMessagesViewController = viewFactory.makeDirectMessagesViewController(for: conversation, activeUser: activeUser)
        addChildViewController(directMessagesViewController)
        view.addSubview(directMessagesViewController.view)
        directMessagesViewController.didMove(toParentViewController: self)
        directMessagesViewController.view.translatesAutoresizingMaskIntoConstraints = false
        directMessagesViewController.view.pin(to: view)
    }
    
    // MARK: - Private Methods
//    @objc private func didPressProfileButton() {
//        let profileViewController = viewFactory.makeProfileViewController(for: conv, activeUser: activeUser)
//        navigationController?.pushViewController(profileViewController, animated: true)
//    }

}
