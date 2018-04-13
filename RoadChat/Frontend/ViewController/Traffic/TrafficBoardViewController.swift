//
//  TrafficBoardViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 01.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class TrafficBoardViewController: UIViewController {
    
    // MARK: - Typealiases
    typealias ColorPalette = KarmaColorPalette
    
    // MARK: - Private Properties
    private let viewFactory: ViewControllerFactory
    private let user: User
    private let colorPalette: ColorPalette
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, activeUser: User, colorPalette: ColorPalette) {
        self.viewFactory = viewFactory
        self.user = activeUser
        self.colorPalette = colorPalette
        
        super.init(nibName: nil, bundle: nil)
        self.title = "Traffic"
        
        tabBarItem = UITabBarItem(title: "Traffic", image: #imageLiteral(resourceName: "car_glyph"), tag: 0)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "create_new_glyph"), style: .plain, target: self, action: #selector(createButtonPressed(_:)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trafficMessagesViewController = viewFactory.makeTrafficMessagesViewController(for: nil, activeUser: user)
        addChildViewController(trafficMessagesViewController)
        view.addSubview(trafficMessagesViewController.view)
        trafficMessagesViewController.didMove(toParentViewController: self)
        trafficMessagesViewController.view.translatesAutoresizingMaskIntoConstraints = false
        trafficMessagesViewController.view.pin(to: view)
    }
    
    // MARK: - Public Methods
    @objc func createButtonPressed(_ sender: UIBarButtonItem) {
        let createMessageViewController = viewFactory.makeCreateTrafficMessageViewController()
        let createMessageNavigationController = UINavigationController(rootViewController: createMessageViewController)
        present(createMessageNavigationController, animated: true, completion: nil)
    }
    
}


