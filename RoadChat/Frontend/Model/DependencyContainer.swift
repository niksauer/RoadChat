//
//  DependencyContainer.swift
//  RoadChat
//
//  Created by Niklas Sauer on 19.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

struct DependencyContainer {
    
    // Private Properties
    private var viewContext: NSManagedObjectContext {
        return CoreDataStack.shared.viewContext
    }
    
//    private var backgroundContext: NSManagedObjectContext {
//        return CoreDataStack.shared.viewContext
//    }
    
    private var userManager: UserManager {
        return UserManager(userService: UserService(config: config), context: viewContext)
    }
    
    private var authenticationManager: AuthenticationManager {
        return AuthenticationManager(credentials: credentials, authenticationService: AuthenticationService(config: config), userManager: userManager, searchContext: viewContext)
    }
    
    private var communityBoard: CommunityBoard {
        return CommunityBoard(communityService: CommunityService(config: config), context: viewContext)
    }
    
    private var trafficBoard: TrafficBoard {
        return TrafficBoard(trafficService: TrafficService(config: config), context: viewContext)
    }
    
    private var colorPalette: ColorContainer {
        return ColorContainer()
    }
    
    private var shortDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        return dateFormatter
    }()
    
    private var timeSinceDateFormatter: DateFormatter {
        return TimeSinceDateFormatter()
    }
    
    private var lengthFormatter: LengthFormatter {
        return LengthFormatter()
    }
    
    private var monthYearDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yyyy"
        return dateFormatter
    }()
    
    // Public Properties
    var appDelegate: AppDelegate!
    let credentials: APICredentialStore = KeychainManager.shared
    let userDefaults: UserDefaults = UserDefaults.standard
    let coreData: CoreDataStack = CoreDataStack.shared
    let locationManager: LocationManager = LocationManager.shared

    
    var config: APIConfiguration {
        return RoadChatAPI(credentials: credentials)
    }
}

extension DependencyContainer: ViewControllerFactory {

    // General
    func makeSetupViewController() -> SetupViewController {
        return SetupViewController(viewFactory: self, appDelegate: appDelegate, authenticationManager: authenticationManager, credentials: credentials)
    }
    
    func makeHomeTabBarController(activeUser user: User) -> HomeTabBarController {
        return HomeTabBarController(viewFactory: self, activeUser: user)
    }

    // Shared
    func makeLocationViewController(for location: CLLocation) -> LocationViewController {
        return LocationViewController(viewFactory: self, location: location)
    }
    
    // Authentication
    func makeAuthenticationViewController() -> UINavigationController {
        return UINavigationController(rootViewController: makeLoginViewController())
    }
    
    func makeLoginViewController() -> LoginViewController {
        return LoginViewController(viewFactory: self, appDelegate: appDelegate, authenticationManager: authenticationManager)
    }

    func makeRegisterViewController() -> RegisterViewController {
        return RegisterViewController(viewFactory: self, appDelegate: appDelegate, authenticationManager: authenticationManager, userManager: userManager)
    }

    // Community
    func makeCommunityBoardViewController(activeUser: User) -> CommunityBoardViewController {
        return CommunityBoardViewController(viewFactory: self, activeUser: activeUser, colorPalette: colorPalette)
    }
    
    func makeCommunityMessagesViewController(for sender: User?, activeUser: User) -> CommunityMessagesViewController {
        return CommunityMessagesViewController(viewFactory: self, communityBoard: communityBoard, sender: sender, activeUser: activeUser, searchContext: viewContext, cellDateFormatter: timeSinceDateFormatter, colorPalette: colorPalette, userManager: userManager)
    }

    func makeCreateCommunityMessageViewController() -> CreateCommunityMessageViewController {
        return CreateCommunityMessageViewController(communityBoard: communityBoard, locationManager: locationManager, colorPalette: colorPalette)
    }
    
    func makeCommunityMessageDetailViewController(for message: CommunityMessage, sender: User, activeUser: User) -> CommunityMessageDetailViewController {
        return CommunityMessageDetailViewController(viewFactory: self, message: message, sender: sender, activeUser: activeUser, dateFormatter: timeSinceDateFormatter, colorPalette: colorPalette)
    }
    
    // Traffic
    func makeTrafficBoardViewController(activeUser: User) -> TrafficBoardViewController {
        return TrafficBoardViewController(viewFactory: self, activeUser: activeUser, colorPalette: colorPalette)
    }
    
    func makeTrafficMessagesViewController(for sender: User?, activeUser: User) -> TrafficMessagesViewController {
        return TrafficMessagesViewController(viewFactory: self, trafficBoard: trafficBoard, sender: sender, activeUser: activeUser, searchContext: viewContext, cellDateFormatter: timeSinceDateFormatter, colorPalette: colorPalette, userManager: userManager)
    }
    
    func makeCreateTrafficMessageViewController() -> CreateTrafficMessageViewController {
        return CreateTrafficMessageViewController(trafficBoard: trafficBoard, locationManager: locationManager, colorPalette: colorPalette)
    }
    
    func makeTrafficMessageDetailViewController(for message: TrafficMessage, sender: User, activeUser: User) -> TrafficMessageDetailViewController {
        return TrafficMessageDetailViewController(viewFactory: self, message: message, sender: sender, activeUser: activeUser, dateFormatter: timeSinceDateFormatter, colorPalette: colorPalette)
    }
    

    // Chat
    func makeConversationsViewController(for user: User) -> ConversationsViewController {
        return ConversationsViewController(viewFactory: self, user: user, searchContext: viewContext, cellDateFormatter: shortDateFormatter)
    }
    
    // User
    func makeSettingsViewController(for user: User, settings: Settings, privacy: Privacy) -> SettingsViewController {
        return SettingsViewController(viewFactory: self, appDelegate: appDelegate, authenticationManager: authenticationManager, user: user, settings: settings, privacy: privacy, colorPalette: colorPalette, lengthFormatter: lengthFormatter)
    }
    
    func makePrivacyViewController(with privacy: Privacy) -> PrivacyViewController {
        return PrivacyViewController(privacy: privacy)
    }
    
    func makeProfileViewController(for user: User) -> ProfileViewController {
        return ProfileViewController(viewFactory: self, user: user, colorPalette: colorPalette)
    }
    
    func makeProfilePageViewController(for user: User) -> ProfilePageViewController {
        return ProfilePageViewController(viewFactory: self, user: user, colorPalette: colorPalette)
    }
    
    // Car
    func makeCarsViewController(for user: User) -> CarsViewController {
        return CarsViewController(viewFactory: self, owner: user, searchContext: viewContext, colorPalette: colorPalette, cellDateFormatter: monthYearDateFormatter)
    }
    
    func makeCarDetailViewController(for car: Car) -> CarDetailViewController {
        return CarDetailViewController(car: car, dateFormatter: monthYearDateFormatter)
    }
    
    // Profile Pages
    func makeAboutViewController(for user: User) -> AboutViewController {
        return AboutViewController(user: user, dateFormatter: shortDateFormatter, registryDateFormatter: timeSinceDateFormatter, colorPalette: colorPalette)
    }

}
