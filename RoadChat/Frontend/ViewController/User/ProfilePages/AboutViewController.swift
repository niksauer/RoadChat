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
    
    // MARK: - Initialization
    init(user: User) {
        self.user = user
        
        super.init(nibName: nil, bundle: nil)
        self.title = "About"
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        communityKarmaLevelLabel.text = "\(user.communityKarma)"
        trafficKarmaLevelLabel.text = "\(user.trafficKarma)"
        
        
        let calendar = Calendar.autoupdatingCurrentCalendar()
        calendar.timeZone = TimeZone.systemTimeZone()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = calendar.timeZone
        let components = calendar.components([ .Month, .Day ],
                                                 fromDate: user.registry, toDate: Date(), options: [])
        
        accountAgeLabel.text = "\(components.day)"
        birthLabel.text = "\(user.profile?.birth)"
        emailLabel.text = user.email
        streetLabel.text = user.profile?.streetName + " " + user.profile?.streetNumber
        postalCodeLabel.text = user.profile?.postalCode
        countryLabel.text = user.profile?.country
        
        
    }
    
}
