//
//  NavigationHelper.swift
//  RoadChat
//
//  Created by Niklas Sauer on 18.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import UIKit

struct NavigationHelper {
    func showHome() {
        let appDelegate = UIApplication.shared.delegate! as! AppDelegate
        let rootController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "tabBarVC")
        appDelegate.window?.rootViewController = rootController
        appDelegate.window?.makeKeyAndVisible()
    }
    
    func showLogin() {
        let appDelegate = UIApplication.shared.delegate! as! AppDelegate
        let rootController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "loginNavigationVC")
        appDelegate.window?.rootViewController = rootController
        appDelegate.window?.makeKeyAndVisible()
    }
}
