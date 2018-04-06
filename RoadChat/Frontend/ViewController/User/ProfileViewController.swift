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
    
    // MARK: - Outlets
    @IBOutlet weak var pageViewContainer: UIView!
    
    // MARK: - Private Properties
    private let viewFactory: ViewControllerFactory
    private let user: User
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, user: User) {
        self.viewFactory = viewFactory
        self.user = user
        
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
