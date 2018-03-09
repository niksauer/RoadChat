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
    
    // MARK: - Public Properties
    let authenticationManager = AuthenticationManager()
    
    // MARK: - Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    // MARK: - Public Methods
    @IBAction func registerButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "showRegisterView", sender: self)
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        guard let user = usernameTextField.text, let password = passwordTextField.text else {
            // handle missing fields error
            log.warning("Missing required fields for login.")
            return
        }
        
        let loginRequest = LoginRequest(user: user, password: password)
        
        authenticationManager.login(loginRequest) { error in
            guard error == nil else {
                // handle login error
                return
            }
            
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.window?.rootViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
        }
    }
    
}
