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
        guard let email = emailTextField.text, let username = usernameTextField.text, let password = passwordTextField.text, let confirmPassword = confirmPasswordTextField.text else {
            // handle missing fields error
            return
        }
       
        if (checkUserInputs(email: email, username: username, password: password, password2: confirmPassword)){
            
        let registerRequest = RegisterRequest(email: email, username: username, password: password)
        
        User.create(registerRequest) { error in
            guard error == nil else {
                print(error!)
                return
            }
        }
        
        print("sucessfull registration")
        self.performSegue(withIdentifier: "showLoginView", sender: self)
        }else{
            //wrong input
        }
        
        
    }

    func checkUserInputs(email: String, username: String, password: String, password2: String) -> Bool{
        
        var validInputs: Bool = true
        
        if checkUsernameValidity(username: username){
            print("valid username")
        } else {
            print("invalid username")
            usernameLabel.textColor = .red
            validInputs = false
        }
        if checkEmailValidity(email: email){
            print("valid email")
        } else {
            print("invalid email")
            emailLabel.textColor = .red
            validInputs = false
        }
        if checkPasswordValidity(password: password){
            print("valid password")
        } else {
            print("invalid password")
            passwordLabel.textColor = .red
            validInputs = false
        }
        if confirmPassword(password1: password, password2: password2){
            print("passwords match")
        } else {
            print("passwords don't match")
            passwordLabel.textColor = .red
            confirmPasswordLabel.textColor = .red
            validInputs = false
        }
        return validInputs
    }
    func checkEmailValidity(email: String) -> Bool{
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    func checkPasswordValidity(password: String) -> Bool{
        let passwordRegEx = "[A-Z0-9a-z!§$%&/()=?`´*'+#',;.:-_@<>^°]{8,}"
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: password)
    }
    func checkUsernameValidity(username: String) -> Bool{
        let usernameRegEx = "[A-Z0-9a-z]{4,}"
        let usernameTest = NSPredicate(format:"SELF MATCHES %@", usernameRegEx)
        return usernameTest.evaluate(with: username)
    }
    func confirmPassword(password1: String, password2: String) -> Bool{
        return password1 == password2
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
