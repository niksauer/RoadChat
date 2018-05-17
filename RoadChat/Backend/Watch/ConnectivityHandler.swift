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

class ConnectivityHandler : NSObject, WCSessionDelegate {
    
    var session = WCSession.default
    
    override init() {
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
        NSLog("didReceiveMessage: %@", message)
        
        createTrafficMessage(type: (message["type"] as? String)!)
    }
    
        private func createTrafficMessage(type: String) {
            
            let trafficType = TrafficType(rawValue: type)
            let location = RoadChatKit.Location(
            coreLocation: <#T##CLLocation#>)
            
            
        }
    

