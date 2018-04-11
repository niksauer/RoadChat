//
//  ProfileViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 01.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import RoadChatKit
import Parchment

class ProfileViewController: UIViewController {
    
    // MARK: - Typealiases
    typealias ColorPalette = BasicColorPalette
    
    // MARK: - Outlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sexImageView: UIImageView!
    @IBOutlet weak var biographyLabel: UILabel!
    
    @IBOutlet weak var pageViewContainer: UIView!
    
    // MARK: - Private Properties
    private let viewFactory: ViewControllerFactory
    private let user: User
    private let colorPalette: ColorPalette
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, user: User, colorPalette: ColorPalette) {
        self.viewFactory = viewFactory
        self.user = user
        self.colorPalette = colorPalette
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = "Profile"
        self.tabBarItem = UITabBarItem(title: "Profile", image: #imageLiteral(resourceName: "contact_card"), tag: 3)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "settings"), style: .done, target: self, action: #selector(settingsButtonPressed(_:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed(_:)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        usernameLabel.text = user.username
        
        if let profile = user.profile {
            let now = Date()
            let birthday: Date = profile.birth!
            let calendar = Calendar.current
            
            let ageComponents = calendar.dateComponents([.year], from: birthday, to: now)
            let age = ageComponents.year!
            
            ageLabel.text = "(\(age)y)"
            nameLabel.text = "\(profile.firstName!) \(profile.lastName!)"
            
            if let sex = profile.storedSex {
                switch sex {
                case .male:
                    sexImageView.image = #imageLiteral(resourceName: "male")
                case .female:
                    sexImageView.image = #imageLiteral(resourceName: "female")
                case .other:
                    sexImageView.image = #imageLiteral(resourceName: "genderqueer")
                }
            } else {
                sexImageView.image = nil
            }
            
            biographyLabel.text = profile.biography
        } else {
            ageLabel.text = nil
            nameLabel.text = nil
            sexImageView.image = nil
            biographyLabel.text = nil
        }
        
        // setup profile page view controller
        let pageViewController = viewFactory.makeProfilePageViewController(for: user)
        addChildViewController(pageViewController)
        pageViewContainer.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pageViewController.view.leadingAnchor.constraint(equalTo: pageViewContainer.leadingAnchor),
            pageViewController.view.topAnchor.constraint(equalTo: pageViewContainer.topAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: pageViewContainer.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: pageViewContainer.bottomAnchor),
        ])
    }
    
    // MARK: - Public Methods
    @objc func settingsButtonPressed(_ sender: UIBarButtonItem) {
        let settingsViewController = viewFactory.makeSettingsViewController(for: user)
        let settingsNavigationViewController = UINavigationController(rootViewController: settingsViewController)
        navigationController?.present(settingsNavigationViewController, animated: true, completion: nil)
    }
    
    @objc func editButtonPressed(_ sender: UIBarButtonItem) {
        
    }
    
}
