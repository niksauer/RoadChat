//
//  DependencyContainer.swift
//  RoadChat
//
//  Created by Niklas Sauer on 19.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation

struct DependencyContainer {}

extension DependencyContainer: ViewControllerFactory {
    
    // General
    func makeSetupViewController() -> SetupViewController {
        return SetupViewController.instantiate(factory: self)
    }
    
    func makeHomeTabBarController(for user: User) -> HomeTabBarController {
        return HomeTabBarController(factory: self, user: user)
    }

    // Authentication
    func makeLoginViewController() -> LoginViewController {
        return LoginViewController.instantiate(factory: self)
    }

    func makeRegisterViewController() -> RegisterViewController {
        return RegisterViewController.instantiate(factory: self)
    }

    // Community
    func makeCommunityBoardViewController() -> CommunityBoardViewController {
        return CommunityBoardViewController.instantiate(factory: self)
    }

    func makeCreateCommunityMessageViewController() -> CreateCommunityMessageViewController {
        return CreateCommunityMessageViewController.instantiate(factory: self)
    }

    // Traffic
    func makeTrafficBoardViewController() -> TrafficBoardViewController {
        return TrafficBoardViewController.instantiate(factory: self)
    }

    // Chat
    func makeConversationsViewController(for user: User) -> ConversationsViewController {
        return ConversationsViewController.instantiate(factory: self, user: user)
    }
    
    // User
    func makeProfileViewController(for user: User) -> ProfileViewController {
        return ProfileViewController.instantiate(factory: self, user: user)
    }

}

// General
extension DependencyContainer: APICredentialStoreFactory {
    func makeAPICredentialStore() -> APICredentialStore {
        return CredentialManager.shared
    }
}

extension DependencyContainer: AuthenticationManagerFactory {
    func makeAuthenticationManager() -> AuthenticationManager {
        return AuthenticationManager(credentials: makeAPICredentialStore())
    }
}

extension DependencyContainer: LocationManagerFactory {
    func makeLocationManager() -> LocationManager {
        return LocationManager()
    }
}

// Community
extension DependencyContainer: CommunityBoardFactory {
    func makeCommunityBoard() -> CommunityBoard {
        return CommunityBoard(credentials: makeAPICredentialStore())
    }
}

// Traffic
extension DependencyContainer: TrafficBoardFactory {
    func makeTrafficBoard() -> TrafficBoard {
        return TrafficBoard(credentials: makeAPICredentialStore())
    }
}

// User
extension DependencyContainer: UserManagerFactory {
    func makeUserManager() -> UserManager {
        return UserManager(credentials: makeAPICredentialStore())
    }
}

// UIHelper
extension DependencyContainer: ViewNavigatorFactory {
    func makeViewNavigator() -> ViewNavigator {
        return ViewNavigator()
    }
}
