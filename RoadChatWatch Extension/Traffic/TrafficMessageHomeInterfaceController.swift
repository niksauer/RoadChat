//
//  TrafficMessageHomeInterfaceController.swift
//  RoadChatWatch Extension
//
//  Created by Malcolm Malam on 16.05.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class TrafficMessageHomeInterfaceController: WKInterfaceController, WCSessionDelegate {

    // MARK: - Private Properties
    private var session: WCSession?
    
    // MARK: - Initialization
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        session = WCSession.default
        session?.delegate = self
        session?.activate()
    }

    // MARK: - WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("session active: \(activationState)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let isLoggedIn = message["isLoggedIn"] as? Bool, !isLoggedIn else {
            return
        }
        
        self.popToRootController()
    }
    
}
