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
    private let colorPalette: ColorPalette
    private let user: User
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, colorPalette: ColorPalette, user: User) {
        self.viewFactory = viewFactory
        self.colorPalette = colorPalette
        self.user = user
        
        super.init(style: .grouped)
        
        self.title = "Security"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            // email
            return 1
        case 1:
            // password
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
        default:
            fatalError()
        }
    }
}
