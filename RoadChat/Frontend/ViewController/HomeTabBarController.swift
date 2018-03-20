//
//  HomeTabBarController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 20.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class HomeTabBarController: UITabBarController {
    
    // MARK: - Public Properties
    typealias Factory = ViewControllerFactory & AuthenticationManagerFactory
    
    // MARK: - Initialization
    init(factory: Factory, user: User) {
        super.init(nibName: nil, bundle: nil)
        
        let communityBoardViewController = factory.makeCommunityBoardViewController()
        let communityBoardNavigationController = UINavigationController(rootViewController: communityBoardViewController)
        communityBoardNavigationController.tabBarItem = UITabBarItem(title: "Community", image: #imageLiteral(resourceName: "collaboration"), tag: 0)
        
        let trafficBoardViewController = factory.makeTrafficBoardViewController()
        let trafficBoardNavigationController = UINavigationController(rootViewController: trafficBoardViewController)
        trafficBoardNavigationController.tabBarItem = UITabBarItem(title: "Traffic", image: #imageLiteral(resourceName: "car"), tag: 1)
        
        let conversationsViewController = factory.makeConversationsViewController(for: user)
        let conversationsNavigationController = UINavigationController(rootViewController: conversationsViewController)
        conversationsNavigationController.tabBarItem = UITabBarItem(title: "Chat", image: #imageLiteral(resourceName: "speech_buble"), tag: 2)
        
        let profileViewController = factory.makeProfileViewController(for: user)
        let profileNavigationController = UINavigationController(rootViewController: profileViewController)
        profileNavigationController.tabBarItem = UITabBarItem(title: "Profile", image: #imageLiteral(resourceName: "contact_card"), tag: 3)
        
        self.viewControllers = [communityBoardNavigationController, trafficBoardNavigationController, conversationsNavigationController, profileNavigationController]
        self.selectedIndex = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
