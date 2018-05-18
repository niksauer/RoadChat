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
    typealias ColorPalette = BasicColorPalette
    
    // MARK: - Private Properties
    private let viewFactory: ViewControllerFactory
    private let user: User
    private let activeUser: User
    private let colorPalette: ColorPalette
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, user: User, activeUser: User, colorPalette: ColorPalette) {
        self.viewFactory = viewFactory
        self.user = user
        self.activeUser = activeUser
        self.colorPalette = colorPalette
        
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = colorPalette.backgroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        let communityViewController = viewFactory.makeCommunityMessagesViewController(for: user, activeUser: activeUser)
        let trafficViewController = viewFactory.makeTrafficMessagesViewController(for: user, activeUser: activeUser)
        let carsViewController = viewFactory.makeCarsViewController(for: user, activeUser:  activeUser)
        let aboutViewController = viewFactory.makeAboutViewController(for: user, activeUser: activeUser)
        
        let pagingViewController = FixedPagingViewController(viewControllers: [communityViewController, trafficViewController, carsViewController, aboutViewController])
        pagingViewController.menuItemSize = .sizeToFit(minWidth: 90, height: 40)
        
        addChildViewController(pagingViewController)
        view.addSubview(pagingViewController.view)
        pagingViewController.didMove(toParentViewController: self)
        pagingViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pagingViewController.view.pin(to: view)
    }
}
