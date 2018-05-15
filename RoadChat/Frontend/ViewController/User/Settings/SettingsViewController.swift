//
//  SettingsViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 22.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, GeofenceViewControllerDelegate {

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
    private let lengthFormatter: LengthFormatter
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, appDelegate: AppDelegate, authenticationManager: AuthenticationManager, user: User, settings: Settings, privacy: Privacy, colorPalette: ColorPalette, lengthFormatter: LengthFormatter) {
        self.viewFactory = viewFactory
        self.appDelegate = appDelegate
        self.authenticationManager = authenticationManager
        self.user = user
        self.settings = settings
        self.privacy = privacy
        self.colorPalette = colorPalette
        self.lengthFormatter = lengthFormatter
        
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
        settings.save { error in
            guard error == nil else {
                // handle error
                return
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - GeofenceViewControllerDelegate
    func didUpdateRadius(_ sender: GeofenceViewController) {
        if sender.identifier == "Community" {
            settings.communityRadius = Int16(sender.radius/1000)
        } else {
            settings.trafficRadius = Int16(sender.radius/1000)
        }
        
        tableView.reloadSections(IndexSet([0]), with: .automatic)
    }
    
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            // radius
            return 2
        case 1:
            // account
            return 3
        case 2:
            // delete account
            return 1
        case 3:
            // developer
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
                let cell = UITableViewCell(style: .value1, reuseIdentifier: "communityRadiusCell")
                cell.textLabel?.text = "Community"
                cell.detailTextLabel?.text = lengthFormatter.string(fromMeters: Double(Int(settings.communityRadius)*1000))
                cell.accessoryType = .disclosureIndicator
                return cell
            case 1:
                // traffic radius
                let cell = UITableViewCell(style: .value1, reuseIdentifier: "trafficRadiusCell")
                cell.textLabel?.text = "Traffic"
                cell.detailTextLabel?.text = lengthFormatter.string(fromMeters: Double(Int(settings.trafficRadius)*1000))
                cell.accessoryType = .disclosureIndicator
                return cell
            default:
                fatalError()
            }
        case 1:
            // account
            switch row {
            case 0:
                // privacy
                let cell = UITableViewCell(style: .default, reuseIdentifier: "privacyCell")
                cell.textLabel?.text = "Privacy"
                cell.accessoryType = .disclosureIndicator
                return cell
            case 1:
                // security
                let cell = UITableViewCell(style: .default, reuseIdentifier: "securityCell")
                cell.textLabel?.text = "Security"
                cell.accessoryType = .disclosureIndicator
                return cell
            case 2:
                // logout
                let cell = UITableViewCell(style: .default, reuseIdentifier: "logoutCell")
                cell.textLabel?.text = "Logout"
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
        case 3:
            // developer
            switch row {
            case 0:
                // log data
                let cell = UITableViewCell(style: .default, reuseIdentifier: "logDataCell")
                cell.textLabel?.text = "Log Data"
                cell.accessoryType = .disclosureIndicator
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
        case 3:
            return "Developer"
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
            switch row {
            case 0:
                let geofenceViewController = viewFactory.makeGeofenceViewController(radius: Double(Int(settings.communityRadius)*1000), min: 0, max: 500*1000, identifier: "Community")
                geofenceViewController.delegate = self
                let geofenceNavigationController = UINavigationController(rootViewController: geofenceViewController)
                navigationController?.present(geofenceNavigationController, animated: true, completion: nil)
            case 1:
                let geofenceViewController = viewFactory.makeGeofenceViewController(radius: Double(Int(settings.trafficRadius)*1000), min: 0, max: 500*1000, identifier: "Traffic")
                geofenceViewController.delegate = self
                let geofenceNavigationController = UINavigationController(rootViewController: geofenceViewController)
                navigationController?.present(geofenceNavigationController, animated: true, completion: nil)
            default:
                fatalError()
            }
        case 1:
            switch row {
            case 0:
                // privacy
                let privacyViewController = viewFactory.makePrivacyViewController(with: privacy)
                self.navigationController?.pushViewController(privacyViewController, animated: true)
            case 1:
                // security
                let securityViewController = viewFactory.makeSecurityViewController(for: user)
                self.navigationController?.pushViewController(securityViewController, animated: true)
            case 2:
                // logout
                authenticationManager.logout { error in
                    guard error == nil else {
                        // handle logout error
                        self.displayAlert(title: "Error", message: "Failed to logout: \(error!)", completion: nil)
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
        case 3:
            switch row {
            case 0:
                let logDataViewController = viewFactory.makeLogDataViewController()
                navigationController?.pushViewController(logDataViewController, animated: true)
            default:
                fatalError()
            }
        default:
            fatalError()
        }
    }
    
}
