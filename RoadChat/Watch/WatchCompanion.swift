//
//  WatchCompanion.swift
//  RoadChat
//
//  Created by Niklas Sauer on 25.05.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import RoadChatKit

struct WatchCompanion: WatchConnectivityManagerTrafficDelegate, WatchConnectivityManagerAuthenticationDelegate, AuthenticationManagerDelegate {
    
    // MARK: - Private Properties
    private let connectivityManager: WatchConnectivityManager
    private let trafficBoard: TrafficBoard
    private let authenticationManager: AuthenticationManager
    
    // MARK: - Initialization
    init(connectivityManager: WatchConnectivityManager, trafficBoard: TrafficBoard, authenticationManager: AuthenticationManager) {
        self.connectivityManager = connectivityManager
        self.trafficBoard = trafficBoard
        self.authenticationManager = authenticationManager
        
        connectivityManager.trafficDelegate = self
        connectivityManager.authenticationDelegate = self
        
        authenticationManager.delegate = self
    }
    
    // MARK: - WatchConnectivityManagerTraffic Delegate
    func watchConnectivityManager(_ connectivityManager: WatchConnectivityManager, didReceiveCreateTrafficMessageRequest type: TrafficType, time: Date) {
        trafficBoard.postMessage(type: type, message: nil, time: time) { error in
            guard error == nil else {
                // handle error
//                switch error {
//                case let error = LocationError.noLocation:
//                    break
//                default:
//                    break
//                }
                
                return
            }
            
            // return success message
        }
    }
    
    // MARK: - WatchConnectivityManagerAuthentication Delegate
    func watchConnectivityManager(_ connectivityManager: WatchConnectivityManager, didReceiveLoginStatusRequest request: [String : Any]) {
        authenticationManager.getAuthenticatedUser { user in
            guard user != nil else {
                connectivityManager.updateLoginState(isLoggedIn: false)
                return
            }
            
            connectivityManager.updateLoginState(isLoggedIn: true)
        }
    }
    
    // MARK: - AuthenticationManager Delegate
    func authenticationManager(_ authenticationManager: AuthenticationManager, didVerifyUserAuthentication isLoggedIn: Bool) {
        connectivityManager.updateLoginState(isLoggedIn: isLoggedIn)
    }
    
}
