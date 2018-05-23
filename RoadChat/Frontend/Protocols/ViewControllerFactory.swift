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
    func makeGeofenceViewController(radius: Double?, min: Double, max: Double, identifier: String) -> GeofenceViewController
    
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
    func makeRadarController(activeUser: User) -> RadarViewController
    func makeConversationsViewController(for user: User) -> ConversationsViewController
    func makeConversationViewController(for conversation: Conversation, activeUser: User) -> ConversationViewController
    func makeDirectMessagesViewController(for conversation: Conversation, activeUser: User) -> DirectMessagesViewController
    func makeParticipantsViewController(for conversation: Conversation, activeUser: User) -> ParticipantsViewController
    func makeChangeTitleViewController(for conversation: Conversation) -> ChangeTitleViewController
    
    // Settings
    func makeSettingsViewController(for user: User, settings: Settings) -> SettingsViewController
    func makePrivacyViewController(with privacy: Privacy) -> PrivacyViewController
    func makeSecurityViewController(for user: User) -> SecurityViewController
    func makeChangePasswordViewController(for user: User) -> ChangePasswordViewController
    func makeChangeEmailViewController(for user: User) -> ChangeEmailViewController
    func makeLogDataViewController() -> LogDataViewController
    
    // User
    func makeProfileViewController(for user: User, activeUser: User, showsPublicProfile: Bool) -> ProfileViewController
    func makeProfilePageViewController(for user: User, activeUser: User) -> ProfilePageViewController
    func makeCreateOrEditCarViewController(for user: User, car: Car?) -> CreateOrEditCarViewController
    func makeCreateOrEditProfileViewController(for user: User) -> CreateOrEditProfileViewController
    
    // Car
    func makeCarsViewController(for user: User, activeUser: User) -> CarsViewController
    func makeCarDetailViewController(for car: Car, activeUser: User) -> CarDetailViewController
    
    // Profile Pages
    func makeAboutViewController(for user: User, activeUser: User) -> AboutViewController

}
