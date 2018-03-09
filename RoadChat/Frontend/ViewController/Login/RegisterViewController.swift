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

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var confirmPasswordLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func confirmRegistrationButtonPressed(_ sender: Any) {
        guard let email = emailTextField.text, let username = usernameTextField.text, let password = passwordTextField.text, let passwordRepeat = confirmPasswordTextField.text else {
            // handle missing fields error
            log.warning("Missing required fields for registration.")
            return
        }
       
        if isValidUserInput(email: email, username: username, password: password, passwordRepeat: passwordRepeat) {
            let registerRequest = RegisterRequest(email: email, username: username, password: password)
        
            UserStore.create(registerRequest) { error in
                guard error == nil else {
                    print(error!)
                    return
                }
            }
            
            log.info("Successful registration.")
            self.performSegue(withIdentifier: "showLoginView", sender: self)
        } else {
            // wrong input
        }
    }

    func isValidUserInput(email: String, username: String, password: String, passwordRepeat: String) -> Bool {
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
            confirmPasswordLabel.textColor = .red
            isValid = false
        }
    
        return isValid
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    func isValidPassword(_ password: String) -> Bool {
        let passwordRegEx = "[A-Z0-9a-z!§$%&/()=?`´*'+#',;.:-_@<>^°]{8,}"
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: password)
    }
    
    func isValidUsername(_ username: String) -> Bool {
        let usernameRegEx = "[A-Z0-9a-z]{4,}"
        let usernameTest = NSPredicate(format:"SELF MATCHES %@", usernameRegEx)
        return usernameTest.evaluate(with: username)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
