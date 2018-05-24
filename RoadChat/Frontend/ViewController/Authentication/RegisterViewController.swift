//
//  RegisterViewController.swift
//  RoadChat
//
//  Created by Malcolm Malam on 08.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import RoadChatKit
import Locksmith

class RegisterViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordRepeatTextField: UITextField!
    
    // MARK: - Private Properties
    private let viewFactory: ViewControllerFactory
    private let appDelegate: AppDelegate
    private let authenticationManager: AuthenticationManager
    private let userManager: UserManager
    private let locationManager: LocationManager
    private let connectivityHandler: ConnectivityHandler
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, appDelegate: AppDelegate, authenticationManager: AuthenticationManager, userManager: UserManager, locationManager: LocationManager, connectivityHandler: ConnectivityHandler) {
        self.viewFactory = viewFactory
        self.appDelegate = appDelegate
        self.authenticationManager = authenticationManager
        self.userManager = userManager
        self.locationManager = locationManager
        self.connectivityHandler = connectivityHandler
        
        super.init(nibName: nil, bundle: nil)
        self.title = "Sign Up"
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
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        guard let email = emailTextField.text, let username = usernameTextField.text, let password = passwordTextField.text, let passwordRepeat = passwordRepeatTextField.text else {
            // handle missing fields error
            log.warning("Missing required fields for registration.")
            return
        }
        
        guard isValidUserInput(email: email, username: username, password: password, passwordRepeat: passwordRepeat) else {
            log.warning("Invalid user input.")
            return
        }
    
        let registerRequest = RegisterRequest(email: email, username: username, password: password)
        
        userManager.createUser(registerRequest) { error in
            guard error == nil else {
                // handle registration error
                return
            }
            
            // auto-login
            let loginRequest = LoginRequest(user: email, password: password)
            
            self.authenticationManager.login(loginRequest) { user, error in
                guard let user = user else {
                    // handle login error
                    self.navigationController?.popViewController(animated: true)
                    return
                }
                
                // configure locationManager
                self.locationManager.managedUser = user
                self.locationManager.startPolling()
                self.locationManager.updateRemoteLocation()
                
                // send successful login message to watch
                if self.connectivityHandler.session.isReachable {
                    self.connectivityHandler.session.sendMessage(["isLoggedIn": true], replyHandler: nil)
                } else {
                   try self.connectivityHandler.session.updateApplicationContex(["isLoggedIn": true])
                }
                let appGroupID = "group.hpe.dhbw.SauerStudios"
                
                if let defaults = UserDefaults(suiteName: appGroupID) {
                    defaults.setValue(true, forKey: "isLoggedIn")
                    defaults.synchronize()
                }
                
                // show home screen
                let homeTabBarController = self.viewFactory.makeHomeTabBarController(activeUser: user)
                self.appDelegate.show(homeTabBarController)
            }
        }
    }

    // MARK: - Private Methods
    private func isValidUserInput(email: String, username: String, password: String, passwordRepeat: String) -> Bool {
        var isValid = true
        
        if !isValidUsername(username) {
            log.warning("Invalid username.")
            isValid = false
        }
        
        if !isValidEmail(email) {
            log.warning("Invalid email.")
            isValid = false
        }
        
        if !isValidPassword(password){
            log.warning("Invalid password.")
            isValid = false
        }
        
        if password != passwordRepeat {
            log.warning("Passwords don't match.")
            passwordRepeatTextField.textColor = .red
            isValid = false
        }
    
        return isValid
    }
    
    /// http://brainwashinc.com/2017/08/18/ios-swift-3-validate-email-password-format/
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegEx = "[A-Z0-9a-z!§$%&/()=?`´*'+#',;.:-_@<>^°]{8,}"
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: password)
    }
    
    private func isValidUsername(_ username: String) -> Bool {
        let usernameRegEx = "[A-Z0-9a-z]{4,}"
        let usernameTest = NSPredicate(format:"SELF MATCHES %@", usernameRegEx)
        return usernameTest.evaluate(with: username)
    }
    
}
