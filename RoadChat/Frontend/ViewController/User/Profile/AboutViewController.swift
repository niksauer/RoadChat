//
//  AboutViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 05.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import RoadChatKit
import Contacts

class AboutViewController: UIViewController {

    // MARK: - Typealiases
    typealias ColorPalette = BasicColorPalette
    
    // MARK: - Outlets
    @IBOutlet weak var aboutStackView: UIStackView!
    @IBOutlet weak var separatorStackView: UIStackView!
    @IBOutlet weak var informationStackView: UIStackView!
    @IBOutlet weak var emailStackView: UIStackView!
    @IBOutlet weak var birthStackView: UIStackView!
    @IBOutlet weak var addressStackView: UIStackView!
    
    @IBOutlet weak var communityKarmaLevelLabel: UILabel!
    @IBOutlet weak var trafficKarmaLevelLabel: UILabel!
    @IBOutlet weak var accountAgeLabel: UILabel!
    @IBOutlet weak var birthLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    // MARK: - Private Properties
    private let viewFactory: ViewControllerFactory
    private let user: User
    private let privacy: Privacy
    private let activeUser: User
    private let dateFormatter: DateFormatter
    private let registryDateFormatter: DateFormatter
    private let colorPalette: ColorPalette
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, user: User, activeUser: User, dateFormatter: DateFormatter, registryDateFormatter: DateFormatter, colorPalette: ColorPalette) {
        self.viewFactory = viewFactory
        self.user = user
        self.privacy = user.privacy!
        self.activeUser = activeUser
        self.dateFormatter = dateFormatter
        self.registryDateFormatter = registryDateFormatter
        self.colorPalette = colorPalette
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = "About"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup view
        let backgroundView = UIView()
        backgroundView.backgroundColor = colorPalette.contentBackgroundColor
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        aboutStackView.insertSubview(backgroundView, at: 0)
        backgroundView.pin(to: aboutStackView)
        
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateUI()
    }
    
    // MARK: - Customization
    func updateUI() {
        // user statistics
        communityKarmaLevelLabel.text = "\(user.communityKarma)"
        trafficKarmaLevelLabel.text = "\(user.trafficKarma)"
        accountAgeLabel.text = registryDateFormatter.string(from: user.registry!)
        
        let isOwner = (user.id == activeUser.id)
        var showsAnyInformation = false
        
        // email
        if isOwner || privacy.showEmail {
            showsAnyInformation = true
            emailLabel.text = user.email!
        } else {
            emailStackView.isHidden = true
        }
        
        if let profile = user.profile {
            // birth
            if let birth = profile.birth, (isOwner || privacy.showBirth) {
                showsAnyInformation = true
                birthLabel.text = dateFormatter.string(from: birth)
                birthStackView.isHidden = false
            } else {
                birthStackView.isHidden = true
            }
            
            // address
            let cnAddress = CNMutablePostalAddress()
            
            if (isOwner || privacy.showStreet) {
                showsAnyInformation = true
                cnAddress.street = "\(profile.streetNumber) \(profile.streetName ?? "")"
            }
            
            if (isOwner || privacy.showCity) {
                showsAnyInformation = true
                cnAddress.postalCode = "\(profile.postalCode)"
                cnAddress.city = "\(profile.city ?? "")"
            }
            
            if (isOwner || privacy.showCountry) {
                showsAnyInformation = true
                cnAddress.country = "\(profile.country ?? "")"
            }
            
            let localizedAddress = CNPostalAddressFormatter.string(from: cnAddress, style: .mailingAddress)
            
            if localizedAddress.count >= 1 {
                showsAnyInformation = true
                addressLabel.text = localizedAddress
                addressStackView.isHidden = false
            } else {
                addressStackView.isHidden = true
            }
        } else {
            birthStackView.isHidden = true
            addressStackView.isHidden = true
        }
        
        if !showsAnyInformation {
            separatorStackView.isHidden = true
            informationStackView.isHidden = true
        }
    }
    
}
