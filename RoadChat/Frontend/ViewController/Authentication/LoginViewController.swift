//
//  LoginViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 22.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import RoadChatKit

class LoginViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - Private Properties
    private let viewFactory: ViewControllerFactory
    private let authenticationManager: AuthenticationManager
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, authenticationManager: AuthenticationManager) {
        self.viewFactory = viewFactory
        self.authenticationManager = authenticationManager
    
        super.init(nibName: nil, bundle: nil)
        self.title = "RoadChat"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        guard let user = usernameTextField.text, !user.isEmpty, let password = passwordTextField.text, !password.isEmpty else {
            // handle missing / empty fields error
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
            let homeTabBarController = self.viewFactory.makeHomeTabBarController(for: user)
            (UIApplication.shared.delegate! as! AppDelegate).show(homeTabBarController)
        }
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        let registerViewController = self.viewFactory.makeRegisterViewController()
        self.navigationController?.pushViewController(registerViewController, animated: true)
    }
        
}

