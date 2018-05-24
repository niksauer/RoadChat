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
    
    // MARK: - Initialization
    init(session: WCSession, trafficBoard: TrafficBoard, locationManager: LocationManager) {
        self.session = session
        self.trafficBoard = trafficBoard
        self.locationManager = locationManager
        
        super.init()
        
        session.delegate = self
        session.activate()
        
        log.info("Watch is paired: \(session.isPaired), Watch App is installed: \(session.isWatchAppInstalled)")
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
    func sendMessage(_ message: [String: Any]) {
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil, errorHandler: { error in
                log.error("Failed to send live message: \(error)")
            })
        } else {
            do {
                try session.updateApplicationContext(message)
            } catch {
                log.error("Failed to update application context: \(error)")
            }
        }
    }
    
    // MARK: - WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        log.debug("activationDidCompleteWith activationState:\(activationState) error: \(error)")
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        log.debug("sessionDidBecomeInactive: \(session)")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        log.debug("sessionDidDeactivate: \(session)")
    }

//    func sessionWatchStateDidChange(_ session: WCSession) {
//        NSLog("%@", "sessionWatchStateDidChange: \(session)")
//    }
    
//    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
//        print("received message from watch: \(message)")
//
//        guard let typeString = message["type"] as? String, let trafficType = TrafficType(rawValue: typeString) else {
//            return
//        }
//
//        createTrafficMessage(type: trafficType)
//    }
    
//    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
//        guard let typeString = userInfo["type"] as? String, let trafficType = TrafficType(rawValue: typeString) else {
//            return
//        }
//
//        createTrafficMessage(type: trafficType)
//    }
    
}

//                    let fileManager = FileManager()
//                    let url = self.connectivityHandler.session.watchDirectoryURL
//                    let preferences = ["isLoggedIn": true]
//                    let dicData = Data(preferences)

