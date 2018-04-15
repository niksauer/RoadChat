//
//  SettingsViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 22.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    // MARK: - Private Properties
    private let viewFactory: ViewControllerFactory
    private let appDelegate: AppDelegate
    private let authenticationManager: AuthenticationManager
    private let user: User
    private let settings: Settings
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, appDelegate: AppDelegate, authenticationManager: AuthenticationManager, user: User, settings: Settings) {
        self.viewFactory = viewFactory
        self.appDelegate = appDelegate
        self.authenticationManager = authenticationManager
        self.user = user
        self.settings = settings
        
        super.init(style: .grouped)
        
        self.title = "Settings"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed(_:)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Public Methods
    @objc func doneButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 1
        case 2:
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
                let cell = UITableViewCell(style: .value1, reuseIdentifier: "communityRadiusCell")
                cell.textLabel?.text = "Community"
                cell.detailTextLabel?.text = String(settings.communityRadius)
                cell.accessoryType = .disclosureIndicator
                return cell
            case 1:
                let cell = UITableViewCell(style: .value1, reuseIdentifier: "trafficRadiusCell")
                cell.textLabel?.text = "Traffic"
                cell.detailTextLabel?.text = String(settings.trafficRadius)
                cell.accessoryType = .disclosureIndicator
                return cell
            default:
                fatalError()
            }
        case 1:
            let cell = UITableViewCell(style: .default, reuseIdentifier: "privacyCell")
            cell.textLabel?.text = "Privacy"
            cell.accessoryType = .disclosureIndicator
            return cell
        case 2:
            switch row {
            case 0:
                // logout
                let cell = UITableViewCell(style: .default, reuseIdentifier: "logoutUserCell")
                cell.textLabel?.text = "Logout"
                return cell
            case 1:
                // delete account
                let cell = UITableViewCell(style: .default, reuseIdentifier: "deleteUserCell")
                cell.textLabel?.text = "Delete Account"
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
            return "Radius"
        default:
            return nil
        }
    }
    
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        
        switch section {
        case 0:
            break
        case 1:
            break
        case 2:
            switch row {
            case 0:
                // logout
                authenticationManager.logout { error in
                    let authenticationViewController = self.viewFactory.makeAuthenticationViewController()
                    self.appDelegate.show(authenticationViewController)
                }
            case 1:
                // delete account
                break
            default:
                fatalError()
            }
            
        default:
            fatalError()
        }
    }
    
}
