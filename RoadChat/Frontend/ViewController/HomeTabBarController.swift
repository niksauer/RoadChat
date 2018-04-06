//
//  HomeTabBarController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 20.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class HomeTabBarController: UITabBarController {
    
    // MARK: - Initialization
    convenience init(viewFactory: ViewControllerFactory, user: User) {
        self.init(nibName: nil, bundle: nil)
        
        let viewControllers: [UIViewController]
        
        let communityBoardViewController = viewFactory.makeCommunityBoardViewController()
        let trafficBoardViewController = viewFactory.makeTrafficBoardViewController()
        let conversationsViewController = viewFactory.makeConversationsViewController(for: user)
        let profileViewController = viewFactory.makeProfileViewController(for: user)
        
        viewControllers = [communityBoardViewController, trafficBoardViewController, conversationsViewController, profileViewController]
        
        self.viewControllers = viewControllers.map { UINavigationController(rootViewController: $0) }
        self.selectedIndex = 0
    }
    
}
