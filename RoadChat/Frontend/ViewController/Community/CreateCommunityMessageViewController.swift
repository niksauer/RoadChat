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
    @IBOutlet weak var titleTextView: UITextView!
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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .done, target: self, action: #selector(sendButtonPressed(_:)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        locationManager.startPolling()
    }
    
    // MARK: - Public Methods
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        locationManager.stopPolling()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func sendButtonPressed(_ sender: UIButton) {
        guard let location = locationManager.lastLocation else {
            log.warning("Failed to retrieve current user location.")
            return
        }
        
        let title = checkTextConstraints(sender: "title", text: titleTextView.text)
        let message = checkTextConstraints(sender: "Message", text: messageTextView.text)
        
        let communityMessageRequest = CommunityMessageRequest(title: title, time: Date(), message: message, location: location)
        
        communityBoard.postMessage(communityMessageRequest) { error in
            guard error == nil else {
                displayAlarm(message: "Message could not be postet")
                return
            }
            
            self.locationManager.stopPolling()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func checkTextConstraints(sender: String, text: String) -> String{
        if (text.count < 1){
            displayAlarm(message: sender + " is empty")
            log.warning("Empty message content.")
            return
        } else if(text.count < 300) {
            return text
        } else {
            displayAlarm(message: sender + " contains too many characters")
            log.warning("Message is too long.")
            return
        }
        
    }
    
    private func displayAlarm(message: String) {
    let alertController = UIAlertController(title: "Error", message:
    message, preferredStyle: UIAlertControllerStyle.alert)
    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
    self.present(alertController, animated: true, completion: nil)
    }
    
}
