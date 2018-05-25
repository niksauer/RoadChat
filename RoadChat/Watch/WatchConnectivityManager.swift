//
//  WatchConnectivityManager.swift
//  RoadChat
//
//  Created by Malcolm Malam on 17.05.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import WatchConnectivity
import RoadChatKit

protocol WatchConnectivityManagerAuthenticationDelegate {
    func watchConnectivityManager(_ connectivityManager: WatchConnectivityManager, didReceiveLoginStatusRequest request: [String: Any])
}

protocol WatchConnectivityManagerTrafficDelegate {
    func watchConnectivityManager(_ connectivityManager: WatchConnectivityManager, didReceiveCreateTrafficMessageRequest type: TrafficType, time: Date)
}

class WatchConnectivityManager: NSObject, WCSessionDelegate {
    
    // MARK: - Singleton
    static let shared = WatchConnectivityManager()
    
    // MARK: - Public Properties
    var authenticationDelegate: WatchConnectivityManagerAuthenticationDelegate?
    var trafficDelegate: WatchConnectivityManagerTrafficDelegate?
    
    // MARK: - Private Properties
    private let session: WCSession
    
    private var shouldCommunicate = false
    
    // MARK: - Initialization
    private override init() {
        self.session = WCSession.default
        
        super.init()
        
        session.delegate = self
        session.activate()
    }
    
    // MARK: - Public Methods
    func updateLoginState(isLoggedIn: Bool) {
        updateApplicationContext(["isLoggedIn": isLoggedIn])
    }
    
    // MARK: - Public Methods
    private func sendMessage(_ message: [String: Any]) {
        guard shouldCommunicate else {
            return
        }
        
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
        guard shouldCommunicate else {
            return
        }
        
        do {
            try session.updateApplicationContext(context)
            log.verbose("Did update application context: \(context)")
        } catch {
            log.error("Failed to update application context: \(error)")
        }
    }
    
    private func processMessage(_ message: [String: Any]) {
        #if os(iOS)
        if let trafficTypeString = message["trafficType"] as? String, let trafficType = TrafficType(rawValue: trafficTypeString) {
            log.debug("Did receive 'trafficType' message with: \(trafficType.rawValue)")
            trafficDelegate?.watchConnectivityManager(self, didReceiveCreateTrafficMessageRequest: trafficType, time: Date())
        }
        
        if let request = message["request"] as? String, request == "loginStatus" {
            log.debug("Did receive 'loginStatus' request.")
            authenticationDelegate?.watchConnectivityManager(self, didReceiveLoginStatusRequest: message)
        }
        #endif
    }
    
    // MARK: - WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        guard error == nil else {
            log.error("Failed to activate session: \(error!)")
            return
        }
        
        log.info("Activated session with state: '\(activationState.rawValue)', \(session.isPaired ? "paired" : "non-paired") Apple Watch and \(session.isWatchAppInstalled ? "installed" : "non-installed") WatchKit extension app.")
        shouldCommunicate = (session.activationState == .activated && session.isPaired && session.isWatchAppInstalled)
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        log.debug("Session did become inactive: \(session)")
        shouldCommunicate = false
    }

    func sessionDidDeactivate(_ session: WCSession) {
        log.debug("Session did deactive: \(session). Attempting to reactivate.")
        session.activate()
    }
    #endif
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        log.debug("Session watch state did change with state: \'\(session.activationState.rawValue)', \(session.isPaired ? "paired" : "non-paired") Apple Watch and \(session.isWatchAppInstalled ? "installed" : "non-installed") WatchKit extension app.")
        shouldCommunicate = session.isPaired && session.isWatchAppInstalled
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

