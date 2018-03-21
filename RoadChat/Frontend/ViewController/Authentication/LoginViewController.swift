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
    
    // MARK: - Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - Public Properties
    typealias Factory = ViewControllerFactory & AuthenticationManagerFactory
    
    // MARK: - Private Properties
    private var factory: Factory!
    private lazy var authenticationManager = factory.makeAuthenticationManager()
    
    // MARK: - Initialization
    class func instantiate(factory: Factory) -> LoginViewController {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        controller.factory = factory
        return controller
    }
    
    // MARK: - Public Methods
    @IBAction func registerButtonPressed(_ sender: Any) {
        let registerViewController = factory.makeRegisterViewController()
        self.navigationController?.pushViewController(registerViewController, animated: true)
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        guard let user = usernameTextField.text, let password = passwordTextField.text else {
            // handle missing fields error
            log.warning("Missing required fields for login.")
            return
        }
        
        let loginRequest = LoginRequest(user: user, password: password)
        
        authenticationManager.login(loginRequest) { user, error in
            guard let user = user else {
                // handle login error
                return
            }
            
            // show home screen
            let homeTabBarController = self.factory.makeHomeTabBarController(for: user)
            (UIApplication.shared.delegate! as! AppDelegate).show(homeTabBarController)
        }
    }
    
}
