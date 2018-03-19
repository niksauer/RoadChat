//
//  SetupViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 18.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class SetupViewController: UIViewController {
    
    // MARK: - Public Properties
    let navigator = NavigationHelper()
    let credentials = CredentialManager.shared
    let userManager = UserManager()
    
    // MARK: - Initialization
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        do {
//            try credentials.setToken(nil)
//            try credentials.setUserID(nil)
//            log.debug("Reset token & userID.")
//        } catch {
//            log.error("Failed to reset token & userID: \(error)")
//        }
        
        // user is logged in if token exists and has userID associated
        let token = credentials.getToken()
        let userID = credentials.getUserID()
        
        if let token = token, let userID = userID {
            log.info("User '\(userID)' is already logged in: \(token)")
            
            if let user = userManager.findUserById(userID) {
                // set active user
                AuthenticationManager.activeUser = user
                log.info("Set currently active user '\(user.id)'.")
                
                // show home screen
                self.navigator.showHome()
            } else {
                userManager.getUserById(userID) { user, error in
                    guard let user = user else {
                        fatalError("Unable to retrieve currently active user: \(error!)")
                    }
                    
                    // set active user
                    AuthenticationManager.activeUser = user
                    log.info("Set currently active user '\(user.id)'.")
                    
                    // show home screen
                    self.navigator.showHome()
                }
            }
        } else {
            if token != nil || userID != nil {
                do {
                    try credentials.setToken(nil)
                    try credentials.setUserID(nil)
                    log.debug("Reset token & userID.")
                } catch {
                    log.error("Failed to reset token and/or userID: \(error)")
                }
            }
            
            // show login view
            navigator.showLogin()
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
