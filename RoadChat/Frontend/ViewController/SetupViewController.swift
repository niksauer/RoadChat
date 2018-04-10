//
//  SetupViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 18.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class SetupViewController: UIViewController {
    
    // MARK: - Private Properties
    private let viewFactory: ViewControllerFactory
    private let appDelegate: AppDelegate
    private let authenticationManager: AuthenticationManager
    private let credentials: APICredentialStore
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, appDelegate: AppDelegate, authenticationManager: AuthenticationManager, credentials: APICredentialStore) {
        self.viewFactory = viewFactory
        self.appDelegate = appDelegate
        self.authenticationManager = authenticationManager
        self.credentials = credentials
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

//        try? credentials.reset()
    
        authenticationManager.getAuthenticatedUser { user in
            guard let user = user else {
                // show authenticationViewController
                let authenticationViewController = self.viewFactory.makeAuthenticationViewController()
                self.appDelegate.show(authenticationViewController)
                return
            }
            
            // show home screen
            let homeTabBarController = self.viewFactory.makeHomeTabBarController(for: user)
            self.appDelegate.show(homeTabBarController)
        }
    }

}
