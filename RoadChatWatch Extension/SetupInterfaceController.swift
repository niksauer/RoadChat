//
//  SetupInterfaceController.swift
//  RoadChatWatch Extension
//
//  Created by Niklas Sauer on 18.05.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import WatchKit
import Foundation

class SetupInterfaceController: WKInterfaceController {
   
    
    // MARK: - Initialization
    override func awake(withContext context: Any?) {
        let appGroupID = "group.com.codingexplorer.WatchDataSharingTutorial"
        let defaults = UserDefaults(suiteName: appGroupID)
        let isLoggedIn = defaults?.bool(forKey: "isLoggedInKey")
        
        if isLoggedIn! {
            self.pushController(withName: "AwaitLogin", context: nil)
        } else {
            self.pushController(withName: "TrafficMessageHome", context: nil)
        }
        super.awake(withContext: context)
    }
    
}
