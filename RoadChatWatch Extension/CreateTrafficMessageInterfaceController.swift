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
    
    var session : WCSession?

    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        session = WCSession.default
        session?.delegate = self
        session?.activate()
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    

    @IBAction func jamButtonPressed() {
    }
    @IBAction func accidentButtonPressed() {
    }
    @IBAction func dangerButtonPressed() {
    }
    @IBAction func detourButtonPressed() {
    }
    
    private func sendTrafficMessage(type: String){
     
        session?.sendMessage(["type" : type],
                             replyHandler: { (response) in
                                print(response)
                                }
        )
        
    }
    
            // MARK: - WCSessionDelegate
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //LOG
    }
    
    
}
