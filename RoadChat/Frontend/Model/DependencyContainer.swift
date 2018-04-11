//
//  DependencyContainer.swift
//  RoadChat
//
//  Created by Niklas Sauer on 19.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import CoreData

struct DependencyContainer {
    
    // Private Properties
    private let appDelegate: AppDelegate = UIApplication.shared.delegate! as! AppDelegate
    private let locationManager: LocationManager = LocationManager.shared
    
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
    
//    private var timeSinceDateFormatter: DateFormatter = {
//        let dateFormatter = DateFormatter()
//        return dateFormatter
//    }()
    
    // Public Properties
    let credentials: APICredentialStore = KeychainManager.shared
    let userDefaults: UserDefaults = UserDefaults.standard
    let coreData: CoreDataStack = CoreDataStack.shared
    
    var config: APIConfiguration {
        return RoadChatAPI(credentials: credentials)
    }
    
}

extension DependencyContainer: ViewControllerFactory {

    // General
    func makeSetupViewController() -> SetupViewController {
        return SetupViewController(viewFactory: self, appDelegate: appDelegate, authenticationManager: authenticationManager, credentials: credentials)
    }
    
    func makeHomeTabBarController(for user: User) -> HomeTabBarController {
        return HomeTabBarController(viewFactory: self, user: user)
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
    func makeCommunityBoardViewController() -> CommunityBoardViewController {
        return CommunityBoardViewController(viewFactory: self, colorPalette: colorPalette)
    }
    
    func makeCommunityMessagesViewController(for user: User?) -> CommunityMessagesViewController {
        return CommunityMessagesViewController(viewFactory: self, communityBoard: communityBoard, user: user, searchContext: viewContext, cellDateFormatter: shortDateFormatter, colorPalette: colorPalette)
    }

    func makeCreateCommunityMessageViewController() -> CreateCommunityMessageViewController {
        return CreateCommunityMessageViewController(communityBoard: communityBoard, locationManager: locationManager, colorPalette: colorPalette)
    }
    
    // Traffic
    func makeTrafficBoardViewController() -> TrafficBoardViewController {
        return TrafficBoardViewController(viewFactory: self, colorPalette: colorPalette)
    }
    
    func makeTrafficMessagesViewController(for user: User?) -> TrafficMessagesViewController {
        return TrafficMessagesViewController(viewFactory: self, trafficBoard: trafficBoard, user: user, searchContext: viewContext, cellDateFormatter: shortDateFormatter, colorPalette: colorPalette)
    }
    
    func makeCreateTrafficMessageViewController() -> CreateTrafficMessageViewController {
        return CreateTrafficMessageViewController(trafficBoard: trafficBoard, locationManager: locationManager)
    }
    

    // Chat
    func makeConversationsViewController(for user: User) -> ConversationsViewController {
        return ConversationsViewController(viewFactory: self, user: user, searchContext: viewContext, cellDateFormatter: shortDateFormatter)
    }
    
    // User
    func makeSettingsViewController(for user: User) -> SettingsViewController {
        return SettingsViewController(viewFactory: self, appDelegate: appDelegate, authenticationManager: authenticationManager, user: user)
    }
    
    func makeProfileViewController(for user: User) -> ProfileViewController {
        return ProfileViewController(viewFactory: self, user: user, colorPalette: colorPalette)
    }
    
    func makeProfilePageViewController(for user: User) -> ProfilePageViewController {
        return ProfilePageViewController(viewFactory: self, user: user, colorPalette: colorPalette)
    }
    
    // Profile Pages
    
    func makeCarsViewController(for user: User) -> CarsViewController {
        return CarsViewController(cars: user.storedCars, dateFormatter: shortDateFormatter)
    }
    
    func makeAboutViewController(for user: User) -> AboutViewController {
        return AboutViewController(user: user)
    }

}
