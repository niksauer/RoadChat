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
    private let user: User
    
    // MARK: - Initialization
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        let communityViewController = CommunityMessagesViewController(messages: nil)
        let trafficViewController = TrafficMessagesViewController(messages: nil)
        let carsViewController = CarsViewController(cars: nil)
        let aboutViewController = AboutViewController(user: user)
        let pagingViewController = FixedPagingViewController(viewControllers: [communityViewController, trafficViewController, carsViewController, aboutViewController])
        pagingViewController.menuItemSize = .sizeToFit(minWidth: 10, height: 40)
        
        addChildViewController(pagingViewController)
        view.addSubview(pagingViewController.view)
        pagingViewController.didMove(toParentViewController: self)
        pagingViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pagingViewController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            pagingViewController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            pagingViewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            pagingViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }
}
