//
//  ProfilePagingController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 05.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import UIKit
import Parchment

class ProfilePageViewController: UIViewController {
    
    // MARK: - Private Properties
    private let viewFactory: ViewControllerFactory
    private let user: User
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, user: User) {
        self.viewFactory = viewFactory
        self.user = user
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        let communityViewController = viewFactory.makeCommunityMessagesViewController(for: user)
        communityViewController.title = "Community"
        
        let trafficViewController = viewFactory.makeTrafficMessagesViewController(for: user)
        let carsViewController = viewFactory.makeCarsViewController(for: user)
        let aboutViewController = viewFactory.makeAboutViewController(for: user)
        
        let pagingViewController = FixedPagingViewController(viewControllers: [communityViewController, trafficViewController, carsViewController, aboutViewController])
        pagingViewController.menuItemSize = .sizeToFit(minWidth: 90, height: 40)
        
        addChildViewController(pagingViewController)
        view.addSubview(pagingViewController.view)
        pagingViewController.didMove(toParentViewController: self)
        pagingViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pagingViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pagingViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pagingViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pagingViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
