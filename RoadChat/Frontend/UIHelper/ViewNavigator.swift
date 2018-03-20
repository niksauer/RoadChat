//
//  ViewNavigator.swift
//  RoadChat
//
//  Created by Niklas Sauer on 18.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import UIKit

struct ViewNavigator {
    func show(_ viewController: UIViewController) {
        let appDelegate = UIApplication.shared.delegate! as! AppDelegate
        appDelegate.window?.rootViewController = viewController
        appDelegate.window?.makeKeyAndVisible()
    }
}
