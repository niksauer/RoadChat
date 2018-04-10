//
//  CreateCommunityMessageViewController.swift
//  RoadChat
//
//  Created by Malcolm Malam on 09.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import RoadChatKit

class CreateCommunityMessageViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!

    // MARK: - Private Properties
    private let communityBoard: CommunityBoard
    private let locationManager: LocationManager
    
    // MARK: - Initialization
    init(communityBoard: CommunityBoard, locationManager: LocationManager) {
        self.communityBoard = communityBoard
        self.locationManager = locationManager
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = "New Post"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed(_:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(postButtonPressed(_:)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        locationManager.startPolling()
    }
    
    // MARK: - Public Methods
    @IBAction func postButtonPressed(_ sender: UIButton) {
        guard let location = locationManager.lastLocation else {
            log.warning("Failed to retrieve current user location.")
            return
        }
        
        guard let title = titleTextField.text, let message = messageTextView.text else {
            // handle missing fields error
            log.warning("Empty message content.")
            return
        }
        
        let communityMessageRequest = CommunityMessageRequest(title: title, time: Date(), message: message, location: location)
        
        communityBoard.postMessage(communityMessageRequest) { error in
            guard error == nil else {
                // handle post error
                return
            }
            
            self.locationManager.stopPolling()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        locationManager.stopPolling()
        self.dismiss(animated: true, completion: nil)
    }

}
