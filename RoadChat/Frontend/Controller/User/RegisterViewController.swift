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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func confirmRegistrationButtonPressed(_ sender: Any) {
        
        let registerClient = UserService()
        let registerRequest = RegisterRequest(email: emailTextField.text!, username: usernameTextField.text!, password: passwordTextField.text!)
        
        do{
            try registerClient.create(registerRequest) { user, error in
                guard let user = user else {
                    print(error!)
                    return
                }

                self.performSegue(withIdentifier: "showLoginView", sender: self)
                print("successful registration")
            }
        } catch {
            //handle body encoding error
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
