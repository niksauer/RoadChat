//
//  ViewControllerFactory.swift
//  RoadChat
//
//  Created by Niklas Sauer on 19.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation

protocol ViewControllerFactory {
    
    // General
    func makeSetupViewController() -> SetupViewController
    func makeHomeTabBarController(for user: User) -> HomeTabBarController
    
    // Authentication
    func makeLoginViewController() -> LoginViewController
    func makeRegisterViewController() -> RegisterViewController
    
    // Community
    func makeCommunityBoardViewController() -> CommunityBoardViewController
    func makeCreateCommunityMessageViewController() -> CreateCommunityMessageViewController
    
    // Traffic
    func makeTrafficBoardViewController() -> TrafficBoardViewController
    
    // Chat
    func makeConversationsViewController(for user: User) -> ConversationsViewController
    
    // User
    func makeProfileViewController(for user: User) -> ProfileViewController
    func makeSettingsViewController(for user: User) -> SettingsViewController
    
}