//
//  CommunityBoardViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 10.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class CommunityBoardViewController: UIViewController{

    // MARK: - Typealiases
    typealias ColorPalette = KarmaColorPalette
    
    // MARK: - Private Properties
    private let viewFactory: ViewControllerFactory
    private let activeUser: User
    private let colorPalette: ColorPalette
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, activeUser: User, colorPalette: ColorPalette) {
        self.viewFactory = viewFactory
        self.activeUser = activeUser
        self.colorPalette = colorPalette
        
        super.init(nibName: nil, bundle: nil)
        self.title = "Community"
        
        tabBarItem = UITabBarItem(title: "Community", image: #imageLiteral(resourceName: "collaboration"), tag: 0)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "create_new"), style: .plain, target: self, action: #selector(createButtonPressed(_:)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        super.viewDidLoad()

        let communityMessagesViewController = viewFactory.makeCommunityMessagesViewController(for: nil, activeUser: activeUser)
        addChildViewController(communityMessagesViewController)
        view.addSubview(communityMessagesViewController.view)
        communityMessagesViewController.didMove(toParentViewController: self)
        communityMessagesViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            communityMessagesViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            communityMessagesViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            communityMessagesViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            communityMessagesViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    // MARK: - Public Methods
    @objc func createButtonPressed(_ sender: UIBarButtonItem) {
        let createMessageViewController = viewFactory.makeCreateCommunityMessageViewController()
        let createMessageNavigationController = UINavigationController(rootViewController: createMessageViewController)
        present(createMessageNavigationController, animated: true, completion: nil)
    }
    
    
   

}
