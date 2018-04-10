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
    private let colorPalette: ColorPalette
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, colorPalette: ColorPalette) {
        self.viewFactory = viewFactory
        self.colorPalette = colorPalette
        
        super.init(nibName: nil, bundle: nil)
        self.title = "Traffic Board"
        
        tabBarItem = UITabBarItem(title: "Traffic", image: #imageLiteral(resourceName: "car"), tag: 0)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "create_new"), style: .plain, target: self, action: #selector(createButtonPressed(_:)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trafficMessagesViewController = viewFactory.makeTrafficMessagesViewController(for: nil)
        addChildViewController(trafficMessagesViewController)
        view.addSubview(trafficMessagesViewController.view)
        trafficMessagesViewController.didMove(toParentViewController: self)
        trafficMessagesViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            trafficMessagesViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trafficMessagesViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            trafficMessagesViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            trafficMessagesViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    // MARK: - Public Methods
    @objc func createButtonPressed(_ sender: UIBarButtonItem) {
        let createMessageViewController = viewFactory.makeCreateTrafficMessageViewController()
        let createMessageNavigationController = UINavigationController(rootViewController: createMessageViewController)
        present(createMessageNavigationController, animated: true, completion: nil)
    }
    
}


