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
    
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        
        self.performSegue(withIdentifier: "registerSegue", sender: self)
        
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        guard let user = usernameTextField.text, let password = passwordTextField.text else {
            // handle missing fields error
            return
        }
        
        let loginRequest = LoginRequest(user: user, password: password)
        
        User.login(loginRequest, completion: { error in
            
        })
    }
}
