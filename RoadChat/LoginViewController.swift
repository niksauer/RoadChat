//
//  LoginViewController.swift
//  RoadChat
//
//  Created by Malcolm Malam on 07.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import UIKit
import RoadChatKit
import Strongbox

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
                let keyChainClient = Strongbox()
                _ = keyChainClient.archive(token, key: "AuthToken")
                print(keyChainClient.unarchive(objectForKey: "AuthToken") as! String)
            }
        } catch {
            print(error)
        }
    }
    
}
