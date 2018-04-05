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
        
        accountAgeLabel.text = DateFormatter().string(from: user.registry!)
        emailLabel.text = user.email
    }

}
