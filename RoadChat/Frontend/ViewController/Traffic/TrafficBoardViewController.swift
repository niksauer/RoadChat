//
//  TrafficBoardViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 01.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import RoadChatKit

class TrafficBoardViewController: UIViewController {
    
    // MARK: - Typealiases
    typealias ColorPalette = KarmaColorPalette
    
    // MARK: - Private Properties
    private let viewFactory: ViewControllerFactory
    private let user: User
    private let colorPalette: ColorPalette
    
    private var filter: TrafficType? {
        didSet {
            guard let trafficMessagesVC = childViewControllers.first as? TrafficMessagesViewController else {
                return
            }
            
            trafficMessagesVC.filter = filter
        }
    }
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, activeUser: User, colorPalette: ColorPalette) {
        self.viewFactory = viewFactory
        self.user = activeUser
        self.colorPalette = colorPalette
        
        super.init(nibName: nil, bundle: nil)
        self.title = "Traffic"
        
        tabBarItem = UITabBarItem(title: "Traffic", image: #imageLiteral(resourceName: "car_glyph"), tag: 0)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filterButtonPressed(_:)))
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
    
    // MARK: - Private Methods
    @objc private func createButtonPressed(_ sender: UIBarButtonItem) {
        let createMessageViewController = viewFactory.makeCreateTrafficMessageViewController()
        let createMessageNavigationController = UINavigationController(rootViewController: createMessageViewController)
        present(createMessageNavigationController, animated: true, completion: nil)
    }
    
    @objc private func filterButtonPressed(_ sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: "Filter by...", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        })
        
        actionSheet.addAction(cancelAction)
        
        let noneAction = UIAlertAction(title: "None", style: .default, handler: { _ in
            self.filter = nil
        })
        
        if filter == nil {
            noneAction.setValue(true, forKey: "checked")
        }
        
        actionSheet.addAction(noneAction)
        
        for type in TrafficType.allCases {
            let action = UIAlertAction(title: type.rawValue.capitalized, style: .default, handler: { action in
                guard let title = action.title, let type = TrafficType(rawValue: title.lowercased()) else {
                    return
                }
                
                self.filter = type
            })
            
            if filter == type {
                action.setValue(true, forKey: "checked")
            }
            
            actionSheet.addAction(action)
        }
        
        self.navigationController?.present(actionSheet, animated: true, completion: nil)
    }
    
}


