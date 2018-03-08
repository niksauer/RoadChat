//
//  LoginViewController.swift
//  RoadChat
//
//  Created by Malcolm Malam on 07.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import RoadChatKit
import Locksmith

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        let loginClient = LoginService()
        let loginRequest = LoginRequest(user: usernameTextField.text!, password: passwordTextField.text!)
        
        do {
            try loginClient.login(loginRequest) { token, error in
                guard let token = token else {
                    log.error("Failed login: \(error!)")
                    return
                }
                
                do {
                    try CredentialManager.shared.setToken(token.token)
                    log.info("Successful login.")
                } catch {
                    // handle keychain error
                    log.error("Failed to set token in keychain: \(error)")
                }
            }
        } catch {
            // handle request error
            log.error("Failed to execute HTTPRequest: \(error)")
        }
    }

}
