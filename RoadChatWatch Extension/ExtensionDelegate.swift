//
//  ExtensionDelegate.swift
//  RoadChatWatch Extension
//
//  Created by Malcolm Malam on 16.05.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import WatchKit
import WatchConnectivity
import SwiftyBeaver

let log = SwiftyBeaver.self
var connectivityManager: WatchConnectivityManager?

class ExtensionDelegate: NSObject, WKExtensionDelegate, WatchConnectivityManagerDelegate {
    
    // Mark: - Private Properties
    private let userDefaults = UserDefaults.standard
    
    // Mark: - ExtensionDelegate
    func applicationDidFinishLaunching() {
        // SwiftyBeaver configuration
        let console = ConsoleDestination()
        console.minLevel = .verbose
        log.addDestination(console)
        
        // start connectivity handler
        if WCSession.isSupported() {
            connectivityManager = WatchConnectivityManager.shared
            connectivityManager?.delegate = self
        } else {
            log.debug("Watch connectivity is not supported.")
        }
        
        // check login status
        if let isLoggedIn = userDefaults.value(forKey: "isLoggedIn") as? Bool {
            let newRootInterfaceController = isLoggedIn ? "TrafficMessageHome" : "AwaitLogin"
            WKInterfaceController.reloadRootPageControllers(withNames: [newRootInterfaceController], contexts: nil, orientation: .horizontal, pageIndex: 0)
        }
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

    // Mark: - WatchConnectivityManagerDelegate    
    func watchConnectivityManager(_ watchConnecitivtyManager: WatchConnectivityManager, didAuthenticateUser isLoggedIn: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(isLoggedIn, forKey: "isLoggedIn")
        userDefaults.synchronize()
        
        let newRootInterfaceController = isLoggedIn ? "TrafficMessageHome" : "AwaitLogin"
        
        OperationQueue.main.addOperation {
            WKInterfaceController.reloadRootPageControllers(withNames: [newRootInterfaceController], contexts: nil, orientation: .horizontal, pageIndex: 0)
        }
    }
    
}
