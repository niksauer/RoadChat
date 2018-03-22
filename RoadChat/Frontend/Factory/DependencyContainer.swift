//
//  DependencyContainer.swift
//  RoadChat
//
//  Created by Niklas Sauer on 19.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation

struct DependencyContainer {
    private let credentials: APICredentialStore = CredentialManager.shared

    private var userManager: UserManager {
        return UserManager(userService: UserService(credentials: credentials))
    }
    
    private var authenticationManager: AuthenticationManager {
        return AuthenticationManager(credentials: credentials, authenticationService: AuthenticationService(credentials: credentials), userManager: userManager)
    }
    
    private var communityBoard: CommunityBoard {
        return CommunityBoard(communityService: CommunityService(credentials: credentials))
    }
    
    private var trafficBoard: TrafficBoard {
        return TrafficBoard(trafficService: TrafficService(credentials: credentials))
    }
}

extension DependencyContainer: ViewControllerFactory {
    
    // General
    func makeSetupViewController() -> SetupViewController {
        return SetupViewController(viewFactory: self, authenticationManager: authenticationManager, credentials: credentials)
    }
    
    func makeHomeTabBarController(for user: User) -> HomeTabBarController {
        return HomeTabBarController(viewFactory: self, user: user)
    }

    // Authentication
    func makeLoginViewController() -> LoginViewController {
        return LoginViewController(viewFactory: self, authenticationManager: authenticationManager)
    }

    func makeRegisterViewController() -> RegisterViewController {
        return RegisterViewController(viewFactory: self, authenticationManager: authenticationManager, userManager: userManager)
    }

    // Community
    func makeCommunityBoardViewController() -> CommunityBoardViewController {
        return CommunityBoardViewController(viewFactory: self, communityBoard: communityBoard)
    }

    func makeCreateCommunityMessageViewController() -> CreateCommunityMessageViewController {
        return CreateCommunityMessageViewController(communityBoard: communityBoard)
    }

    // Traffic
    func makeTrafficBoardViewController() -> TrafficBoardViewController {
        return TrafficBoardViewController(viewFactory: self, trafficBoard: trafficBoard)
    }

    // Chat
    func makeConversationsViewController(for user: User) -> ConversationsViewController {
        return ConversationsViewController(viewFactory: self, user: user)
    }
    
    // User
    func makeProfileViewController(for user: User) -> ProfileViewController {
        return ProfileViewController(viewFactory: self, authenticationManager: authenticationManager, user: user)
    }

}
