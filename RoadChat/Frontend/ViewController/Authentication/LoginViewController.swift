//
//  LoginViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 22.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import RoadChatKit
import WatchConnectivity

class LoginViewController: UIViewController {
    
    static var loginState: Bool = false
    
    // MARK: - Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - Private Properties
    private let viewFactory: ViewControllerFactory
    private let appDelegate: AppDelegate
    private let authenticationManager: AuthenticationManager
    private let locationManager: LocationManager
    private let connectivityHandler: ConnectivityHandler!
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, appDelegate: AppDelegate, authenticationManager: AuthenticationManager, locationManager: LocationManager) {
        self.viewFactory = viewFactory
        self.appDelegate = appDelegate
        self.authenticationManager = authenticationManager
        self.locationManager = locationManager
        self.connectivityHandler = (UIApplication.shared.delegate as? AppDelegate)?.connectivityHandler
        
        super.init(nibName: nil, bundle: nil)
        self.title = "RoadChat"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // MARK: - Public Methods
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
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
            
            // configure locationManager
            self.locationManager.managedUser = user
            self.locationManager.startPolling()
            
            // send successful login message to watch
            do {
                try self.connectivityHandler.session.updateApplicationContext(["isLoggedIn": true])
            } catch {
                log.error("Failed to update login status on Apple Watch: \(error)")
            }
            
            // show home screen
            let homeTabBarController = self.viewFactory.makeHomeTabBarController(activeUser: user)
            self.appDelegate.show(homeTabBarController)
        }
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        let registerViewController = self.viewFactory.makeRegisterViewController()
        navigationController?.pushViewController(registerViewController, animated: true)
    }
        
}

