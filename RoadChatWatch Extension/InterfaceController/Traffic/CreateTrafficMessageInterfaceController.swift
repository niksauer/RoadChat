//
//  CreateTrafficMessageInterfaceController.swift
//  RoadChatWatch Extension
//
//  Created by Malcolm Malam on 16.05.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import WatchKit

class CreateTrafficMessageInterfaceController: WKInterfaceController, ConnectivityHandlerDelegate {
 
    // MARK: - Customization
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        super.willActivate()
    }
    
    // MARK: - Public Methods
    @IBAction func jamButtonPressed() {
        connectivityHandler?.sendTrafficMessage(type: .jam)
        self.pop()
    }

    @IBAction func detourButtonPressed() {
        connectivityHandler?.sendTrafficMessage(type: .detour)
        self.pop()
    }
    
    @IBAction func accidentButtonPressed() {
        connectivityHandler?.sendTrafficMessage(type: .accident)
        self.pop()
    }

    @IBAction func dangerButtonPressed() {
        connectivityHandler?.sendTrafficMessage(type: .danger)
        self.pop()
    }

}
