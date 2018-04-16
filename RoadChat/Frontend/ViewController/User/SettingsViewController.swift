//
//  SettingsViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 22.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    // MARK: - Typealiases
    typealias ColorPalette = BasicColorPalette
    
    // MARK: - Private Properties
    private let viewFactory: ViewControllerFactory
    private let appDelegate: AppDelegate
    private let authenticationManager: AuthenticationManager
    private let user: User
    private let settings: Settings
    private let privacy: Privacy
    private let colorPalette: ColorPalette
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, appDelegate: AppDelegate, authenticationManager: AuthenticationManager, user: User, settings: Settings, privacy: Privacy, colorPalette: ColorPalette) {
        self.viewFactory = viewFactory
        self.appDelegate = appDelegate
        self.authenticationManager = authenticationManager
        self.user = user
        self.settings = settings
        self.privacy = privacy
        self.colorPalette = colorPalette
        
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
        
        tableView.register(UINib(nibName: "CenterLabelCell", bundle: nil), forCellReuseIdentifier: "CenterLabelCell")
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
            return 2
        case 2:
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
                let cell = UITableViewCell(style: .value1, reuseIdentifier: "communityRadiusCell")
                cell.textLabel?.text = "Community"
                
                let lengthFormatter = LengthFormatter()
                print(lengthFormatter.string(fromValue: Double(settings.communityRadius), unit: .kilometer))
                print(lengthFormatter.string(fromMeters: Double(settings.communityRadius/1000)))
                
                print(lengthFormatter.unitString(fromValue: Double(settings.communityRadius), unit: .kilometer))
                let formattedLength = lengthFormatter.unitString(fromValue: Double(settings.communityRadius), unit: .kilometer)
                
                
                cell.detailTextLabel?.text = formattedLength
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
            switch row {
            case 0:
                let cell = UITableViewCell(style: .default, reuseIdentifier: "privacyCell")
                cell.textLabel?.text = "Privacy"
                cell.accessoryType = .disclosureIndicator
                return cell
            case 1:
                // logout
                let cell = UITableViewCell(style: .default, reuseIdentifier: "logoutCell")
                cell.textLabel?.text = "Logout"
                return cell
            default:
                fatalError()
            }
        case 2:
            switch row {
            case 0:
                // delete account
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
            return "Radius"
        case 1:
            return "Account"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Defines the radius around your current location in which a message must have been posted in order to be displayed."
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
            switch row {
            case 0:
                // privacy
                let privacyViewController = viewFactory.makePrivacyViewController(with: privacy)
                self.navigationController?.pushViewController(privacyViewController, animated: true)
            case 1:
                // logout
                authenticationManager.logout { error in
                    guard error == nil else {
                        // handle logout error
                        self.displayAlert(title: "Error", message: "Failed to logout: \(error!)")
                        return
                    }
                    
                    let authenticationViewController = self.viewFactory.makeAuthenticationViewController()
                    self.appDelegate.show(authenticationViewController)
                }
            default:
                fatalError()
            }
        case 2:
            switch row {
            case 0:
                // delete account
                authenticationManager.deleteAuthenticatedUser { error in
                    guard error == nil else {
                        // handle delete user account error
                        self.displayAlert(title: "Error", message: "Failed to delete account: \(error!)")
                        return
                    }
                    
                    let authenticationViewController = self.viewFactory.makeAuthenticationViewController()
                    self.appDelegate.show(authenticationViewController)
                }
            default:
                fatalError()
            }
        default:
            fatalError()
        }
    }
    
}
