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
    typealias ColorPalette = BasicColorPalette & SexColorPalette
    
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
    private let privacy: Privacy
    private let activeUser: User
    private let colorPalette: ColorPalette
    
    // MARK: - Views
    private var refreshControl: UIRefreshControl?
    
    // MARK: - Public Properties
    var showsPublicProfile: Bool = false {
        didSet {
            if showsPublicProfile {
                self.navigationItem.leftBarButtonItem = nil
                self.navigationItem.rightBarButtonItem = nil
            }
        }
    }
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, user: User, activeUser: User, colorPalette: ColorPalette) {
        self.viewFactory = viewFactory
        self.user = user
        self.privacy = user.privacy!
        self.activeUser = activeUser
        self.colorPalette = colorPalette
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = "Profile"
        self.tabBarItem = UITabBarItem(title: "Profile", image: #imageLiteral(resourceName: "profile_glyph"), tag: 3)
        
        if activeUser.id == user.id {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "settings_glyph"), style: .done, target: self, action: #selector(settingsButtonPressed(_:)))
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed(_:)))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        super.viewDidLoad()
        // pull to refresh
//        refreshControl = UIRefreshControl()
//        refreshControl?.layer.zPosition = -1
//        refreshControl?.addTarget(self, action: #selector(updateData), for: .valueChanged)
//        view.addSubview(refreshControl!)
        
        // profile image appearance
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
        
        // setup UI
        updateUI()
        
        // setup profile page view controller
        let pageViewController = viewFactory.makeProfilePageViewController(for: user, activeUser: activeUser)
        addChildViewController(pageViewController)
        pageViewContainer.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.view.pin(to: pageViewContainer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateUI()
    }
    
    // MARK: - Public Methods
    @objc func updateData() {
        user.getProfile { user in
            self.updateUI()
        }
    }
    
    func updateUI() {
        let isOwner = (user.id == activeUser.id)
        
        // username
        usernameLabel.text = user.username
        
        if let profile = user.profile {
            // age
            if privacy.showBirth || isOwner {
                let calendar = Calendar.current
                let ageComponents = calendar.dateComponents([.year], from: profile.birth!, to: Date())
                let age = ageComponents.year!
                ageLabel.text = "(\(age)y)"
            } else {
                ageLabel.text = nil
            }
            
            // full name
            nameLabel.text = "\(profile.firstName!) \(profile.lastName!)"
            
            // sex
            if let sex = profile.storedSex, privacy.showSex || isOwner {
                switch sex {
                case .male:
                    sexImageView.image = #imageLiteral(resourceName: "male")
                    sexImageView.tintColor = colorPalette.maleColor
                case .female:
                    sexImageView.image = #imageLiteral(resourceName: "female")
                    sexImageView.tintColor = colorPalette.femaleColor
                case .other:
                    sexImageView.image = #imageLiteral(resourceName: "genderqueer")
                    sexImageView.tintColor = colorPalette.otherColor
                }
            } else {
                sexImageView.image = nil
                sexImageView.tintColor = nil
            }
            
            // biography
            if privacy.showBiography || isOwner {
                if let biography = profile.biography {
                    // localized quotation marks
                    let locale = Locale.current
                    let quoteBegin = locale.quotationBeginDelimiter ?? "\""
                    let quoteEnd = locale.quotationEndDelimiter ?? "\""
                    
                    biographyLabel.text = "\(quoteBegin)\(biography)\(quoteEnd)"
                } else {
                    biographyLabel.text = nil
                }
            } else {
                biographyLabel.text = nil
            }
        } else {
            ageLabel.text = nil
            nameLabel.text = nil
            sexImageView.image = nil
            biographyLabel.text = nil
        }
    }
    
    @objc func settingsButtonPressed(_ sender: UIBarButtonItem) {
        guard let settings = user.settings else {
            user.getSettings { error in
                guard error == nil else {
                    // handle failed settings request error
                    return
                }
                
                self.settingsButtonPressed(sender)
            }
            
            // handle no settings error
            return
        }
        
        let settingsViewController = viewFactory.makeSettingsViewController(for: user, settings: settings)
        let settingsNavigationViewController = UINavigationController(rootViewController: settingsViewController)
        navigationController?.present(settingsNavigationViewController, animated: true, completion: nil)
    }
    
    @objc func editButtonPressed(_ sender: UIBarButtonItem) {
        let createProfileViewController = viewFactory.makeCreateOrEditProfileViewController(for: user)
        let createProfileNavigationController = UINavigationController(rootViewController: createProfileViewController)
        present(createProfileNavigationController, animated: true, completion: nil)
    }
    
}
