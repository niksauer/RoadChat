//
//  SecurityViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 18.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class SecurityViewController: UITableViewController {

    // MARK: - Typealiases
    typealias ColorPalette = BasicColorPalette
    
    // MARK: - Private Properties
    private let viewFactory: ViewControllerFactory
    private let appDelegate: AppDelegate
    private let authenticationManager: AuthenticationManager
    private let colorPalette: ColorPalette
    private let user: User
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, appDelegate: AppDelegate, authenticationManager: AuthenticationManager, colorPalette: ColorPalette, user: User) {
        self.viewFactory = viewFactory
        self.appDelegate = appDelegate
        self.authenticationManager = authenticationManager
        self.colorPalette = colorPalette
        self.user = user
        
        super.init(style: .grouped)
        
        self.title = "Security"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "CenterLabelCell", bundle: nil), forCellReuseIdentifier: "CenterLabelCell")
    }
    
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            // email
            return 1
        case 1:
            // password
            return 1
        case 2:
            // delete account
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
            // radius
            switch row {
            case 0:
                // community radius
                let cell = UITableViewCell(style: .default, reuseIdentifier: "emailCell")
                cell.textLabel?.text = user.email
                cell.accessoryType = .disclosureIndicator
                return cell
            default:
                fatalError()
            }
        case 1:
            // account
            switch row {
            case 0:
                // traffic radius
                let cell = UITableViewCell(style: .value1, reuseIdentifier: "changePasswordCell")
                cell.textLabel?.text = "Change Password"
                cell.textLabel?.textColor = colorPalette.tintColor
                return cell
            default:
                fatalError()
            }
        case 2:
            // delete account
            switch row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CenterLabelCell", for: indexPath) as! CenterLabelCell
                cell.centerTextLabel.text = "Delete Account"
                cell.centerTextLabel.textColor = colorPalette.destructiveColor
                return cell
            default:
                fatalError()
            }
        default:
            fatalError()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Email"
        case 1:
            return "Password"
        case 2:
            return nil
        default:
            fatalError()
        }
    }
    
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        
        switch section {
        case 0:
            switch row {
            case 0:
                let changeEmailViewController = viewFactory.makeChangeEmailViewController(for: user)
                self.navigationController?.pushViewController(changeEmailViewController, animated: true)
                break
            default:
                fatalError()
            }
        case 1:
            switch row {
            case 0:
                let changePasswordViewController = viewFactory.makeChangePasswordViewController(for: user)
                let changePasswordNavigationController = UINavigationController(rootViewController: changePasswordViewController)
                self.navigationController?.present(changePasswordNavigationController, animated: true)
            default:
                fatalError()
            }
        case 2:
            switch row {
            case 0:
                // delete account
                displayConfirmationDialog(title: "Delete Account", message: "Do you really want to delete your account? This includes all data and messages received.", type: .destructive, onCancel: nil) { _ in
                    self.authenticationManager.deleteAuthenticatedUser { error in
                        guard error == nil else {
                            // handle delete user account error
                            self.displayAlert(title: "Error", message: "Failed to delete account: \(error!)", completion: nil)
                            return
                        }
                        
                        let authenticationViewController = self.viewFactory.makeAuthenticationViewController()
                        self.appDelegate.show(authenticationViewController)
                    }
                }
                
                tableView.deselectRow(at: indexPath, animated: false)
            default:
                fatalError()
            }
        default:
            fatalError()
        }
    }
}
