//
//  SetupInterfaceController.swift
//  RoadChatWatch Extension
//
//  Created by Niklas Sauer on 18.05.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class SetupInterfaceController: WKInterfaceController, WCSessionDelegate {
   
    // MARK: - Private Properties
    private var session: WCSession?
    
    // MARK: - Initialization
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        print("hello from Setup")
        
        
        
        
    }
    
    override func willActivate() {
        print("Setup will appear")
        
        session = WCSession.default
        session?.delegate = self
        session?.activate()
        
        let appGroupID = "group.hpe.dhbw.SauerStudios"
        let defaults = UserDefaults(suiteName: appGroupID)
        
        guard let isLoggedIn = defaults?.bool(forKey: "isLoggedInKey") else {
            return
        }
        
        print("has login status: \(isLoggedIn)")
        
        if !isLoggedIn {
            print("attempting to show await login")
//            self.presentController(withName: "AwaitLogin", context: nil)
            self.pushController(withName: "AwaitLogin", context: nil)

        } else {
            
            self.pushController(withName: "TrafficMessageHome", context: nil)
        }
    }
    
    // MARK: - WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        OperationQueue.main.addOperation {
            print(message)
        }
        
        guard let isLoggedIn = message["isLoggedIn"] as? Bool, isLoggedIn else {
            return
        }
        
        OperationQueue.main.addOperation {
            self.pushController(withName: "TrafficMessageHome", context: nil)
        }
        
    }
    
}
