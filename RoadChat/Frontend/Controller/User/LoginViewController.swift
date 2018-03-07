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
                    print(error!)
                    return
                }
                
                do {
                    try CredientialManager.shared.setToken(token.token)
                    print("successful login")
                } catch {
                    // handle keychain error
                }
            }
        } catch {
            // handle body encoding error
        }
    }
}
