//
//  ChangePasswordViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 18.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import RoadChatKit
import ToolKit

class ChangePasswordViewController: UITableViewController {

    // MARK: - Views
    private var changeBarButton: UIBarButtonItem!
    
    // MARK: - Private Properties
    private let user: User
    
    private var password: String? {
        didSet {
            validateChangeButton()
        }
    }
    
    private var passwordRepeat: String? {
        didSet {
            validateChangeButton()
        }
    }
    
    // MARK: - Initialization
    init(user: User) {
        self.user = user
        
        super.init(style: .grouped)
        
        self.title = "Change Password"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didPressCancelButton(_:)))
        changeBarButton = UIBarButtonItem(title: "Change", style: .done, target: self, action: #selector(didPressChangeButton(_:)))
        self.navigationItem.rightBarButtonItem = changeBarButton
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: "TextFieldCell")
        
        tableView.allowsSelection = false
        changeBarButton.isEnabled = false
    }
    
    // MARK: - Public Methods
    @objc func didPressCancelButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func didPressChangeButton(_ sender: UIBarButtonItem) {
        guard let password = password else {
            return
        }
        
        let request = UserRequest(email: nil, username: nil, password: password)
        
        user.update(to: request) { error in
            guard error == nil else {
                // handle error
                self.displayAlert(title: "Error", message: "Failed to change password: \(error!)") {
                    self.dismiss(animated: true, completion: nil)
                }
                
                return
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }

    @objc func didChangePassword(_ sender: UITextField) {
        password = sender.text
    }
    
    @objc func didChangePasswordRepeat(_ sender: UITextField) {
        passwordRepeat = sender.text
    }
    
    func validateChangeButton() {
        guard let password = password, password.count >= 8, let passwordRepeat = passwordRepeat else {
            changeBarButton.isEnabled = false
            return
        }
        
        changeBarButton.isEnabled = (password == passwordRepeat)
    }
    
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        default:
            fatalError()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        
        switch section {
        case 0:
            switch row {
            case 0:
                // new password
                let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldCell
                cell.textField.isSecureTextEntry = true
                cell.textField.placeholder = "New password"
                cell.textField.addTarget(self, action: #selector(didChangePassword(_:)), for: .editingChanged)
                return cell
            case 1:
                // repeat new password
                let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldCell
                cell.textField.isSecureTextEntry = true
                cell.textField.placeholder = "Repeat password"
                cell.textField.addTarget(self, action: #selector(didChangePasswordRepeat(_:)), for: .editingChanged)
                return cell
            default:
                fatalError()
            }
        default:
            fatalError()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return "The password must have at least 8 characters and may only contain valid ASCII characters."
        default:
            fatalError()
        }
    }
    
}
