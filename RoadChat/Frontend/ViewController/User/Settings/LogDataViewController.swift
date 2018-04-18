//
//  LogDataViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 16.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class LogDataViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var textView: UITextView!
    
    // MARK: - Private Properties
    let path: URL
    
    // MARK: - Initialization
    init(path: URL) {
        self.path = path
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = "Log Data"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            let log = try String(contentsOf: path, encoding: .utf8)
            textView.text = log
        } catch let error {
            log.debug("Failed to load log from file: \(error)")
        }
    }

}
