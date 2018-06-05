//
//  CreateTrafficMessageInterfaceController.swift
//  RoadChatWatch Extension
//
//  Created by Malcolm Malam on 16.05.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import WatchKit
import Foundation

class CreateTrafficMessageInterfaceController: WKInterfaceController {
 
    // MARK: - Customization
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        super.willActivate()
    }
    
    // MARK: - Public Methods
    @IBAction func jamButtonPressed() {
        connectivityManager?.sendTrafficMessage(type: .jam)
        self.pop()
    }

    @IBAction func detourButtonPressed() {
        connectivityManager?.sendTrafficMessage(type: .detour)
        self.pop()
    }
    
    @IBAction func accidentButtonPressed() {
        connectivityManager?.sendTrafficMessage(type: .accident)
        self.pop()
    }

    @IBAction func dangerButtonPressed() {
        connectivityManager?.sendTrafficMessage(type: .danger)
        self.pop()
    }

}
