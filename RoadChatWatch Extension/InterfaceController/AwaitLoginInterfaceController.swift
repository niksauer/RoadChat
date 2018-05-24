//
//  AwaitLoginInterfaceController.swift
//  RoadChatWatch Extension
//
//  Created by Niklas Sauer on 18.05.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import WatchKit
import Foundation

class AwaitLoginInterfaceController: WKInterfaceController, ConnectivityHandlerDelegate {
    
    // MARK: - Customization
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        super.willActivate()
//        connectivityHandler?.delegate = self
    }
    
    // MARK: - ConnectivityHandler Delegate
//    func didChangeLoginState(_ isLoggedIn: Bool) {
//        guard isLoggedIn else {
//            return
//        }
//
//        WKInterfaceController.reloadRootPageControllers(withNames: ["TrafficMessageHome"], contexts: nil, orientation: .horizontal, pageIndex: 0)
//    }
    
}
