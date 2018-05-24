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
import RoadChatKitWatch

protocol ConnectivityHandlerDelegate {
//    func didChangeLoginState(_ isLoggedIn: Bool)
}

class ConnectivityHandler: NSObject, WCSessionDelegate {
    
    // MARK: - Singleton
    static let shared = ConnectivityHandler(session: WCSession.default)
    
    // MARK: - Public Properties
    var delegate: ConnectivityHandlerDelegate?
    
    // MARK: - Private Properties
    private let session: WCSession
    
    // MARK: - Initialization
    private init(session: WCSession) {
        self.session = session
        
        super.init()
        
        session.delegate = self
        session.activate()
    }
    
    // MARK: - Public Methods
    func sendTrafficMessage(type: TrafficType) {
        sendMessage(["trafficType": type.rawValue])
    }
    
    // MARK: - Private Methods
    private func sendMessage(_ message: [String: Any]) {
        if session.isReachable {
            log.verbose("Will send live message.")
            session.sendMessage(message, replyHandler: nil, errorHandler: { error in
                log.error("Failed to send live message: \(error)")
            })
        } else {
            do {
                log.verbose("Will update application context.")
                try session.updateApplicationContext(message)
            } catch {
                log.error("Failed to update application context: \(error)")
            }
        }
    }
    
    private func processMessage(_ message: [String: Any]) {
        if let isLoggedIn = message["isLoggedIn"] as? Bool {
            log.debug("Received isLoggedIn message with: \(isLoggedIn)")
            let newRootInterfaceController = isLoggedIn ? "TrafficMessageHome" : "AwaitLogin"
            
            OperationQueue.main.addOperation {
                WKInterfaceController.reloadRootPageControllers(withNames: [newRootInterfaceController], contexts: nil, orientation: .horizontal, pageIndex: 0)
            }
        }
    }
    
    // MARK: - WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        log.info("Activated session with: activation state '\(activationState.rawValue)'.")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        processMessage(message)
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        processMessage(applicationContext)
    }
    
}
