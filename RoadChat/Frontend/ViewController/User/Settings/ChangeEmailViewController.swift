//
//  ChangeEmailViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 18.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import RoadChatKit

class ChangeEmailViewController: UITableViewController {

    // MARK: - Views
    private var doneBarButton: UIBarButtonItem!
    
    // MARK: - Private Properties
    private let user: User
    
    private var email: String? {
        didSet {
            validateDoneButton()
        }
    }
    
    // MARK: - Initialization
    init(user: User) {
        self.user = user
        
        super.init(style: .grouped)
        
        self.title = "Email"
        doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didPressDoneButton(_:)))
        self.navigationItem.rightBarButtonItem = doneBarButton
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "TextFieldCell", bundle: nil), forCellReuseIdentifier: "TextFieldCell")
        tableView.allowsSelection = false
        doneBarButton.isEnabled = false
    }
    
    // MARK: - Public Methods
    @objc func didPressDoneButton(_ sender: UIBarButtonItem) {
        guard let email = email else {
            return
        }
    
        let request = UserRequest(email: email, username: nil, password: nil)
        
        user.update(to: request) { error in
            guard error == nil else {
                // handle error
                self.displayAlert(title: "Error", message: "Failed to update email: \(error!)") {
                    self.dismiss(animated: true, completion: nil)
                }
                
                return
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }

    func didChangeEmail(_ sender: UITextField) {
        email = sender.text
    }
    
    func validateDoneButton() {
        guard let email = email, isValidEmail(email) else {
            doneBarButton.isEnabled = false
            return
        }
        
        doneBarButton.isEnabled = (email != user.email)
    }
    
    // MARK: - Private Methods
    func isValidEmail(_ email: String) -> Bool {
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let pred = NSPredicate(format:"SELF MATCHES %@", regEx)
        return pred.evaluate(with: email)
    }
    
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
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
                cell.textField.placeholder = "Enter email"
                cell.textField.text = user.email
                cell.textField.textContentType = .emailAddress
                cell.configure(text: "Email", onChange: didChangeEmail(_:))
                return cell
            default:
                fatalError()
            }
        default:
            fatalError()
        }
    }
    
}
