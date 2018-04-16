//
//  ViewControllerFactory.swift
//  RoadChat
//
//  Created by Niklas Sauer on 19.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

protocol ViewControllerFactory {
    
    // General
    func makeSetupViewController() -> SetupViewController
    func makeHomeTabBarController(activeUser: User) -> HomeTabBarController
    
    // Shared
    func makeLocationViewController(for location: CLLocation) -> LocationViewController
    func makeGeofenceViewController(radius: Double?) -> filteredLocationController
    
    // Authentication
    func makeAuthenticationViewController() -> UINavigationController
    func makeLoginViewController() -> LoginViewController
    func makeRegisterViewController() -> RegisterViewController
    
    // Community
    func makeCommunityBoardViewController(activeUser: User) -> CommunityBoardViewController
    func makeCommunityMessagesViewController(for sender: User?, activeUser: User) -> CommunityMessagesViewController
    func makeCreateCommunityMessageViewController() -> CreateCommunityMessageViewController
    func makeCommunityMessageDetailViewController(for message: CommunityMessage, sender: User, activeUser: User) -> CommunityMessageDetailViewController
    
    // Traffic
    func makeTrafficBoardViewController(activeUser: User) -> TrafficBoardViewController
    func makeTrafficMessagesViewController(for sender: User?, activeUser: User) -> TrafficMessagesViewController
    func makeCreateTrafficMessageViewController() -> CreateTrafficMessageViewController
    func makeTrafficMessageDetailViewController(for message: TrafficMessage, sender: User, activeUser: User) -> TrafficMessageDetailViewController
    
    // Chat
    func makeConversationsViewController(for user: User) -> ConversationsViewController
    
    // User
    func makeSettingsViewController(for user: User, settings: Settings, privacy: Privacy) -> SettingsViewController
    func makePrivacyViewController(with privacy: Privacy) -> PrivacyViewController
    func makeProfileViewController(for user: User) -> ProfileViewController
    func makeProfilePageViewController(for user: User) -> ProfilePageViewController
    func makeCreateCarViewController(for user: User) -> CreateCarViewController
    func makeCreateProfileViewController(for user: User) -> EditProfileViewController
    
    // Car
    func makeCarsViewController(for user: User) -> CarsViewController
    func makeCarDetailViewController(for car: Car) -> CarDetailViewController
    
    // Profile Pages
    func makeAboutViewController(for user: User) -> AboutViewController

}
