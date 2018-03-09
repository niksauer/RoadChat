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

    // MARK: - Public Properties
    let userStore = UserStore()
    let authenticationManager = AuthenticationManager()
    
    // MARK: - Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordRepeatTextField: UITextField!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordRepeatLabel: UILabel!
    
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
        
        userStore.create(registerRequest) { error in
            guard error == nil else {
                // handle registration error
                return
            }
            
            // auto-login
            let loginRequest = LoginRequest(user: email, password: password)
            
            self.authenticationManager.login(loginRequest) { error in
                guard error == nil else {
                    // handle login error
                    self.performSegue(withIdentifier: "showLoginView", sender: self)
                    return
                }
                
                self.performSegue(withIdentifier: "showTabBarVC", sender: self)
            }
        }
    }

    // MARK: - Private Methods
    private func isValidUserInput(email: String, username: String, password: String, passwordRepeat: String) -> Bool {
        var isValid = true
        
        if !isValidUsername(username) {
            log.warning("Invalid username.")
            usernameLabel.textColor = .red
            isValid = false
        }
        
        if !isValidEmail(email) {
            log.warning("Invalid email.")
            emailLabel.textColor = .red
            isValid = false
        }
        
        if !isValidPassword(password){
            log.warning("Invalid password.")
            passwordLabel.textColor = .red
            isValid = false
        }
        
        if password != passwordRepeat {
            log.warning("Passwords don't match.")
            passwordLabel.textColor = .red
            passwordRepeatTextField.textColor = .red
            isValid = false
        }
    
        return isValid
    }
    
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
