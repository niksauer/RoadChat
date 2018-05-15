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
    convenience init(viewFactory: ViewControllerFactory, activeUser: User, privacy: Privacy) {
        self.init(nibName: nil, bundle: nil)
        
        let viewControllers: [UIViewController]
        
        let communityBoardViewController = viewFactory.makeCommunityBoardViewController(activeUser: activeUser)
        let trafficBoardViewController = viewFactory.makeTrafficBoardViewController(activeUser: activeUser)
        let conversationsViewController = viewFactory.makeConversationsViewController(for: activeUser)
        let profileViewController = viewFactory.makeProfileViewController(for: activeUser, privacy: privacy, activeUser: activeUser)
        
        viewControllers = [communityBoardViewController, trafficBoardViewController, conversationsViewController, profileViewController]
        
        self.viewControllers = viewControllers.map { UINavigationController(rootViewController: $0) }
        self.selectedIndex = 0
    }
    
}
