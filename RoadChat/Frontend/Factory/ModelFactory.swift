//
//  ModelFactory.swift
//  RoadChat
//
//  Created by Niklas Sauer on 19.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation

// General
protocol APICredentialStoreFactory {
    func makeAPICredentialStore() -> APICredentialStore
}

protocol AuthenticationManagerFactory {
    func makeAuthenticationManager() -> AuthenticationManager
}

protocol LocationManagerFactory {
    func makeLocationManager() -> LocationManager
}

// Community
protocol CommunityBoardFactory {
    func makeCommunityBoard() -> CommunityBoard
}

// Traffic
protocol TrafficBoardFactory {
    func makeTrafficBoard() -> TrafficBoard
}

// User
protocol UserManagerFactory {
    func makeUserManager() -> UserManager
}

// UIHelper
protocol ViewNavigatorFactory {
    func makeViewNavigator() -> ViewNavigator
}
