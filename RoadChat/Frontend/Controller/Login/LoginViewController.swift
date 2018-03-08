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
import FBSDKLoginKit
import FBSDKCoreKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
   
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        //do something
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("logout")
    }
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var fbLoginButton: FBSDKButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       self.fbLoginButton.delegate = self.view.center
        
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "showRegisterView", sender: self)
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        guard let user = usernameTextField.text, let password = passwordTextField.text else {
            // handle missing fields error
            return
        }
        
        let loginRequest = LoginRequest(user: user, password: password)
        
        User.login(loginRequest) { error in
            guard error == nil else {
                print(error!)
                return
            }
            
            print("login successfull")
            self.performSegue(withIdentifier: "showTabBarVC", sender: self)
        }
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
