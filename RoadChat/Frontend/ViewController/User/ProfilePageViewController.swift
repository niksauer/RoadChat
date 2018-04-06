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
    private let dateFormatter: DateFormatter
    
    // MARK: - Initialization
    init(user: User, dateFormatter: DateFormatter) {
        self.user = user
        self.dateFormatter = dateFormatter
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        let communityViewController = CommunityMessagesViewController(messages: nil)
        let trafficViewController = TrafficMessagesViewController(messages: nil)
        let carsViewController = CarsViewController(cars: nil, dateFormatter: dateFormatter)
        let aboutViewController = AboutViewController(user: user)
        
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
