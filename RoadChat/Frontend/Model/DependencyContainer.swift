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
    private let credentials: APICredentialStore = CredentialManager.shared
    private let appDelegate: AppDelegate = UIApplication.shared.delegate! as! AppDelegate
    private let locationManager: LocationManager = LocationManager.shared
    
    private var viewContext: NSManagedObjectContext {
        return CoreDataStack.shared.viewContext
    }
    
//    private var backgroundContext: NSManagedObjectContext {
//        return CoreDataStack.shared.viewContext
//    }
    
    private var userManager: UserManager {
        return UserManager(userService: UserService(credentials: credentials), context: viewContext)
    }
    
    private var authenticationManager: AuthenticationManager {
        return AuthenticationManager(credentials: credentials, authenticationService: AuthenticationService(credentials: credentials), userManager: userManager, searchContext: viewContext)
    }
    
    private var communityBoard: CommunityBoard {
        return CommunityBoard(communityService: CommunityService(credentials: credentials), context: viewContext)
    }
    
    private var trafficBoard: TrafficBoard {
        return TrafficBoard(trafficService: TrafficService(credentials: credentials), context: viewContext)
    }
    
    private var karmaColorPalette: KarmaColorPalette {
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
    func makeLoginViewController() -> LoginViewController {
        return LoginViewController(viewFactory: self, appDelegate: appDelegate, authenticationManager: authenticationManager)
    }

    func makeRegisterViewController() -> RegisterViewController {
        return RegisterViewController(viewFactory: self, appDelegate: appDelegate, authenticationManager: authenticationManager, userManager: userManager)
    }

    // Community
    func makeCommunityBoardViewController() -> CommunityBoardViewController {
        return CommunityBoardViewController(viewFactory: self, karmaColorPalette: karmaColorPalette)
    }
    
    func makeCommunityMessagesViewController(for user: User?) -> CommunityMessagesViewController {
        return CommunityMessagesViewController(viewFactory: self, communityBoard: communityBoard, user: user, searchContext: viewContext, cellDateFormatter: shortDateFormatter, karmaColorPalette: karmaColorPalette)
    }

    func makeCreateCommunityMessageViewController() -> CreateCommunityMessageViewController {
        return CreateCommunityMessageViewController(communityBoard: communityBoard, locationManager: locationManager)
    }
    
    // Traffic
    func makeTrafficBoardViewController() -> TrafficBoardViewController {
        return TrafficBoardViewController(viewFactory: self, trafficBoard: trafficBoard, searchContext: viewContext, cellDateFormatter: shortDateFormatter)
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
        return ProfileViewController(viewFactory: self, user: user)
    }
    
    func makeProfilePageViewController(for user: User) -> ProfilePageViewController {
        return ProfilePageViewController(viewFactory: self, user: user)
    }
    
    // Profile Pages    
    func makeTrafficMessagesViewController(for user: User) -> TrafficMessagesViewController {
        return TrafficMessagesViewController(messages: user.storedTrafficMessages, cellDateFormatter: shortDateFormatter)
    }
    
    func makeCarsViewController(for user: User) -> CarsViewController {
        return CarsViewController(cars: user.storedCars, dateFormatter: shortDateFormatter)
    }
    
    func makeAboutViewController(for user: User) -> AboutViewController {
        return AboutViewController(user: user)
    }

}
