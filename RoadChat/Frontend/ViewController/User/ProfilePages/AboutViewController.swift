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
    private let dateFormatter: DateFormatter
    private let registryDateFormatter: DateFormatter
    private let colorPalette: ColorPalette
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, user: User, dateFormatter: DateFormatter, registryDateFormatter: DateFormatter, colorPalette: ColorPalette) {
        self.viewFactory = viewFactory
        self.user = user
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
        
        // user statistics
        communityKarmaLevelLabel.text = "\(user.communityKarma)"
        trafficKarmaLevelLabel.text = "\(user.trafficKarma)"
        accountAgeLabel.text = registryDateFormatter.string(from: user.registry!)
        
        // email
        emailLabel.text = user.email!
        
        if let profile = user.profile {
            // birth
            if let birth = profile.birth {
                birthLabel.text = dateFormatter.string(from: birth)
            } else {
                birthStackView.removeFromSuperview()
            }
            
            // address
            let cnAddress = CNMutablePostalAddress()
            cnAddress.street = "\(profile.streetNumber) \(profile.streetName ?? "")"
            cnAddress.postalCode = "\(profile.postalCode)"
            cnAddress.city = "\(profile.city ?? "")"
            cnAddress.country = "\(profile.country ?? "")"
            
            let localizedAddress = CNPostalAddressFormatter.string(from: cnAddress, style: .mailingAddress)
            
            if localizedAddress.count >= 1 {
                addressLabel.text = localizedAddress
            } else {
                addressStackView.removeFromSuperview()
            }
        } else {
            birthStackView.removeFromSuperview()
            addressStackView.removeFromSuperview()
        }
    }

}
