//
//  AboutViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 05.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var communityKarmaLevelLabel: UILabel!
    @IBOutlet weak var trafficKarmaLevelLabel: UILabel!
    @IBOutlet weak var accountAgeLabel: UILabel!
    @IBOutlet weak var birthLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var postalCodeLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    
    // MARK: - Private Properties
    private let user: User
    private let dateFormatter: DateFormatter
    
    // MARK: - Initialization
    init(user: User, dateFormatter: DateFormatter) {
        self.user = user
        self.dateFormatter = dateFormatter
        
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
        communityKarmaLevelLabel.text = "\(user.communityKarma)"
        trafficKarmaLevelLabel.text = "\(user.trafficKarma)"
        accountAgeLabel.text = dateFormatter.string(from: user.registry!)
        
        emailLabel.text = user.email
        
        if let profile = user.profile {
            if let birth = profile.birth {
                birthLabel.text = dateFormatter.string(from: birth)
            }
            
            if let streetName = profile.streetName {
                streetLabel.text = "\(streetName) \(profile.streetNumber)"
            }
            
            postalCodeLabel.text = String(profile.postalCode)
            countryLabel.text = profile.country
        
        }
    }
    
}
