//
//  AboutViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 05.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    // MARK: - Typealiases
    typealias ColorPalette = BasicColorPalette
    
    // MARK: - Outlets
    @IBOutlet weak var aboutStackView: UIStackView!
    
    @IBOutlet weak var communityKarmaLevelLabel: UILabel!
    @IBOutlet weak var trafficKarmaLevelLabel: UILabel!
    @IBOutlet weak var accountAgeLabel: UILabel!
    @IBOutlet weak var birthLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var streetLabel: UILabel!
    
    // MARK: - Private Properties
    private let user: User
    private let dateFormatter: DateFormatter
    private let colorPalette: ColorPalette
    
    // MARK: - Initialization
    init(user: User, dateFormatter: DateFormatter, colorPalette: ColorPalette) {
        self.user = user
        self.dateFormatter = dateFormatter
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
        backgroundView.backgroundColor = colorPalette.contentBackgroundClor
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        aboutStackView.insertSubview(backgroundView, at: 0)
        backgroundView.pin(to: aboutStackView)
        
        // set content
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
        }
    }
    
}
