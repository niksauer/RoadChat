//
//  ViewControllerFactory.swift
//  RoadChat
//
//  Created by Niklas Sauer on 19.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import UIKit

protocol ViewControllerFactory {
    
    // General
    func makeSetupViewController() -> SetupViewController
    func makeHomeTabBarController(for user: User) -> HomeTabBarController
    
    // Authentication
    func makeAuthenticationViewController() -> UINavigationController
    func makeLoginViewController() -> LoginViewController
    func makeRegisterViewController() -> RegisterViewController
    
    // Community
    func makeCommunityBoardViewController() -> CommunityBoardViewController
    func makeCommunityMessagesViewController(for user: User?) -> CommunityMessagesViewController
    func makeCreateCommunityMessageViewController() -> CreateCommunityMessageViewController
    func makeCommunityMessageDetailViewController(for message: CommunityMessage) -> CommunityMessageDetailViewController
    
    // Traffic
    func makeTrafficBoardViewController() -> TrafficBoardViewController
    func makeTrafficMessagesViewController(for user: User?) -> TrafficMessagesViewController
    func makeCreateTrafficMessageViewController() -> CreateTrafficMessageViewController
    
    // Chat
    func makeConversationsViewController(for user: User) -> ConversationsViewController
    
    // User
    func makeSettingsViewController(for user: User) -> SettingsViewController
    func makeProfileViewController(for user: User) -> ProfileViewController
    func makeProfilePageViewController(for user: User) -> ProfilePageViewController
    
    // Profile Pages
    func makeCarsViewController(for user: User) -> CarsViewController
    func makeAboutViewController(for user: User) -> AboutViewController

}
