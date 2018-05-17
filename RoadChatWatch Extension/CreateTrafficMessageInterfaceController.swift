//
//  CreateTrafficMessageInterfaceController.swift
//  RoadChatWatch Extension
//
//  Created by Malcolm Malam on 16.05.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import WatchKit
import RoadChatKitWatch
import WatchConnectivity

class CreateTrafficMessageInterfaceController: WKInterfaceController, WCSessionDelegate {
    
    // MARK: - Private Properties
    private var session: WCSession?

    // MARK: - Initialization
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        session = WCSession.default
        session?.delegate = self
        session?.activate()
        
        // Configure interface objects here.
    }
    
    // MARK: - Private Methods
    @IBAction private func jamButtonPressed() {
        sendTrafficMessage(type: .jam)
    }
    
    @IBAction private func accidentButtonPressed() {
        sendTrafficMessage(type: .accident)
    }
    
    @IBAction private func dangerButtonPressed() {
        sendTrafficMessage(type: .danger)
    }
    
    @IBAction private func detourButtonPressed() {
        sendTrafficMessage(type: .detour)
    }
    
    private func sendTrafficMessage(type: TrafficType) {
        session?.sendMessage(["type" : type.rawValue], replyHandler: { response in
            // handle response from iPhone
            print(response)
        })
    }
    
    // MARK: - WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("session active")
    }
    
}
