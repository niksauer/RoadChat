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
    private var errorString: String
    
    // MARK: - Initialization
    init(session: WCSession, trafficBoard: TrafficBoard, locationManager: LocationManager) {
        self.session = session
        self.trafficBoard = trafficBoard
        self.locationManager = locationManager
        errorString = ""
        super.init()
        
        session.delegate = self
        session.activate()
        
        NSLog("%@", "Paired Watch: \(session.isPaired), Watch App Installed: \(session.isWatchAppInstalled)")
    }
    
    // MARK: - WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        NSLog("%@", "activationDidCompleteWith activationState:\(activationState) error:\(error)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        NSLog("%@", "sessionDidBecomeInactive: \(session)")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        NSLog("%@", "sessionDidDeactivate: \(session)")
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        NSLog("%@", "sessionWatchStateDidChange: \(session)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("received message from watch: \(message)")
        
        guard let typeString = message["type"] as? String, let trafficType = TrafficType(rawValue: typeString) else {
            return
        }
    
        createTrafficMessage(type: trafficType)
        replyHandler(["type" : errorString])
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
                self.errorString = "\(error)"
                // handle traffic board error -> return failure message
                return
            }
            
            // return success message
            self.errorString = "success"
        }
    }

}

