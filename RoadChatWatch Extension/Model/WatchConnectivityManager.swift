//
//  ConnectivityHandler.swift
//  RoadChatWatch Extension
//
//  Created by Niklas Sauer on 24.05.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import RoadChatKit

protocol WatchConnectivityManagerDelegate {
    func watchConnectivityManager(_ watchConnecitivtyManager: WatchConnectivityManager, didAuthenticateUser isLoggedIn: Bool)
}

class WatchConnectivityManager: NSObject, WCSessionDelegate {
    
    // MARK: - Singleton
    static let shared = WatchConnectivityManager()
    
    // MARK: - Public Properties
    var delegate: WatchConnectivityManagerDelegate?
    
    // MARK: - Private Properties
    private let session: WCSession
    
    // MARK: - Initialization
    private override init() {
        self.session = WCSession.default
        
        super.init()
        
        session.delegate = self
        session.activate()
    }
    
    // MARK: - Public Methods
    func sendTrafficMessage(type: TrafficType) {
        sendMessage(["trafficType": type.rawValue])
    }
    
    func requestLoginStatus() {
        sendMessage(["request": "loginStatus"])
    }
    
    // MARK: - Private Methods
    private func sendMessage(_ message: [String: Any]) {
        if session.isReachable {
            log.verbose("Will send live message.")
            session.sendMessage(message, replyHandler: nil, errorHandler: { error in
                log.error("Failed to send live message: \(error)")
            })
        } else {
            session.transferUserInfo(message)
        }
    }
    
    private func updateApplicationContext(_ context: [String: Any]) {
        do {
            try session.updateApplicationContext(context)
            log.verbose("Did update application context: \(context)")
        } catch {
            log.error("Failed to update application context: \(error)")
        }
    }
    
    private func processMessage(_ message: [String: Any]) {
        if let isLoggedIn = message["isLoggedIn"] as? Bool {
            log.debug("Did receive 'isLoggedIn' message with: \(isLoggedIn)")
            delegate?.watchConnectivityManager(self, didAuthenticateUser: isLoggedIn)
        }
    }
    
    // MARK: - WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        guard error == nil else {
            log.error("Failed to activate session: \(error!)")
            return
        }
        
        log.info("Activated session with state: '\(activationState.rawValue)'")
    }
    
    // received queued messages
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        processMessage(message)
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        processMessage(userInfo)
    }
    
    // received replaced messages
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        processMessage(applicationContext)
    }
    
    // transmission handling
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        guard error == nil else {
            log.error("Failed to transfer user info: \(error!)")
            return
        }
        
        log.verbose("Transfered user info: \(userInfoTransfer)")
    }
    
}
