//
//  ConnectivityHandler.swift
//  RoadChat
//
//  Created by Malcolm Malam on 17.05.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import WatchConnectivity
import RoadChatKit

class ConnectivityHandler: NSObject, WCSessionDelegate {
    
    // MARK: - Private Properties
    private let session: WCSession
    private let trafficBoard: TrafficBoard
    private let locationManager: LocationManager
    
    private var shouldCommunicate = false
    
    // MARK: - Initialization
    init(session: WCSession, trafficBoard: TrafficBoard, locationManager: LocationManager) {
        self.session = session
        self.trafficBoard = trafficBoard
        self.locationManager = locationManager
        
        super.init()
        
        session.delegate = self
        session.activate()
    }
    
    // MARK: - Private Methods
    private func createTrafficMessage(type: TrafficType) {
        guard let location = locationManager.lastLocation else {
            // handle no location error
            return
        }
        
        let request = TrafficMessageRequest(type: type, time: Date(), message: nil, location: RoadChatKit.Location(coreLocation: location))
        
        trafficBoard.postMessage(request) { error in
            guard error == nil else {
                // handle traffic board error -> return failure message
                return
            }
            
            // return success message
        }
    }
    
    // MARK: - Public Methods
    func updateLoginState(isLoggedIn: Bool) {
        sendMessage(["isLoggedIn": isLoggedIn])
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
            do {
                log.verbose("Will update application context.")
                try session.updateApplicationContext(message)
            } catch {
                log.error("Failed to update application context: \(error)")
            }
        }
    }
    
    private func processMessage(_ message: [String: Any]) {
        if let trafficTypeString = message["trafficType"] as? String, let trafficType = TrafficType(rawValue: trafficTypeString) {
            log.debug("Received trafficType message with: \(trafficType)")
            
            guard let location = locationManager.lastLocation else {
                // handle no location error
                return
            }
            
            let messageRequest = TrafficMessageRequest(type: trafficType, time: Date(), message: nil, location: RoadChatKit.Location(coreLocation: location))
            
            trafficBoard.postMessage(messageRequest) { error in
                guard error == nil else {
                    // handle post error
                    return
                }
            }
        }
    }
    
    // MARK: - WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        log.info("Activated session with: activation state '\(activationState.rawValue)', \(session.isPaired ? "paired" : "non-paired") Apple Watch and \(session.isWatchAppInstalled ? "installed" : "non-installed") WatchKit extension app.")
        shouldCommunicate = (session.activationState == .activated && session.isPaired && session.isWatchAppInstalled)
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
//        log.info("sessionDidBecomeInactive: \(session)")
    }

    func sessionDidDeactivate(_ session: WCSession) {
//        log.info("sessionDidDeactivate: \(session)")
    }

    func sessionWatchStateDidChange(_ session: WCSession) {
        log.debug("sessionWatchStateDidCange: \(session)")
        shouldCommunicate = session.isPaired && session.isWatchAppInstalled
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        processMessage(message)
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        processMessage(applicationContext)
    }
    
}

