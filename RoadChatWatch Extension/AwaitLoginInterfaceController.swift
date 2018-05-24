//
//  AwaitLoginInterfaceController.swift
//  RoadChatWatch Extension
//
//  Created by Niklas Sauer on 18.05.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class AwaitLoginInterfaceController: WKInterfaceController, WCSessionDelegate {

    // MARK: - Private Properties
    private var session: WCSession?
    
    // MARK: - Initialization
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        session = WCSession.default
        session?.delegate = self
        session?.activate()
        
        showTrafficHomeIfPossible()
    }
    
    // MARK: - Private Methods
    private func showTrafficHomeIfPossible() {
        let appGroupID = "group.hpe.dhbw.SauerStudios"
        let defaults = UserDefaults(suiteName: appGroupID)
        
        guard let isLoggedIn = defaults?.bool(forKey: "isLoggedInKey") else {
            return
        }
        
        print("login status: \(isLoggedIn)")
        
        if isLoggedIn {
            OperationQueue.main.addOperation {
                WKInterfaceController.reloadRootPageControllers(withNames: ["TrafficMessageHome"], contexts: nil, orientation: .horizontal, pageIndex: 0)
            }
        }
    }
    
    // MARK: - WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("(AwaitLogin) received message: \(applicationContext)")
        
        guard let isLoggedIn = applicationContext["isLoggedIn"] as? Bool, isLoggedIn else {
            return
        }
        
        OperationQueue.main.addOperation {
            WKInterfaceController.reloadRootPageControllers(withNames: ["TrafficMessageHome"], contexts: nil, orientation: .horizontal, pageIndex: 0)
        }
        
    }
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("(AwaitLogin) received message: \(message)")
        
        guard let isLoggedIn = message["isLoggedIn"] as? Bool, isLoggedIn else {
            return
        }
        
        OperationQueue.main.addOperation {
            WKInterfaceController.reloadRootPageControllers(withNames: ["TrafficMessageHome"], contexts: nil, orientation: .horizontal, pageIndex: 0)
        }
        
//        showTrafficHomeIfPossible()
    }
    
}

