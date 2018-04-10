//
//  CreateCommunityMessageViewController.swift
//  RoadChat
//
//  Created by Malcolm Malam on 09.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import RoadChatKit

class CreateCommunityMessageViewController: UIViewController, UITextViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var messageTextView: UITextView!
    
    @IBOutlet weak var titleCharacterCountLabel: UILabel!
    @IBOutlet weak var messageCharacterCountLabel: UILabel!

    // MARK: - Private Properties
    private let communityBoard: CommunityBoard
    private let locationManager: LocationManager
    
    private var sendBarButtonItem: UIBarButtonItem!
    
    private let maxTitleCharacters = 140
    private let maxMessageCharacters = 280
    
    private var titleCharacterCount: Int = 0 {
        didSet {
            titleCharacterCountLabel.text = "\(titleCharacterCount)/\(maxTitleCharacters)"
        }
    }
    
    private var messageCharacterCount: Int = 0 {
        didSet {
            messageCharacterCountLabel.text = "\(messageCharacterCount)/\(maxMessageCharacters)"
        }
    }
    
    // MARK: - Initialization
    init(communityBoard: CommunityBoard, locationManager: LocationManager) {
        self.communityBoard = communityBoard
        self.locationManager = locationManager
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = "New Post"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed(_:)))
        self.sendBarButtonItem = UIBarButtonItem(title: "Send", style: .done, target: self, action: #selector(sendButtonPressed(_:)))
        self.sendBarButtonItem.isEnabled = false
        self.navigationItem.rightBarButtonItem = sendBarButtonItem
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        messageTextView.delegate = self
        titleTextView.delegate = self
        
        titleCharacterCount = 0
        messageCharacterCount = 0

        locationManager.startPolling()
    }
    
    // MARK: - Public Methods
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
        textView.textColor = UIColor.black
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == messageTextView, textView.text.count == 0 {
            textView.textColor = UIColor.lightGray
            textView.text = "(Optional)"
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if (textView == titleTextView) {
            titleCharacterCount = textView.text.count
            
            if (titleCharacterCount >= 1) {
                sendBarButtonItem.isEnabled = true
            } else if (titleCharacterCount >= 140) {
                sendBarButtonItem.isEnabled = false
            } else {
                sendBarButtonItem.isEnabled = false
            }
        }
        
        if (textView == messageTextView) {
            messageCharacterCount = textView.text.count
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // always allow backspace
        let char = text.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        
        if (isBackSpace == -92) {
            // backspace pressed
            return true
        }
        
        if (textView == messageTextView) {
            if (textView.text.count < 280){
                return true
            } else {
                return false
            }
        }
        
        if (textView == titleTextView) {
            if (textView.text.count < 140) {
                return true
            } else {
                return false
            }
        }
        
        return true
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        locationManager.stopPolling()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func sendButtonPressed(_ sender: UIButton) {
        guard let location = locationManager.lastLocation else {
            log.warning("Failed to retrieve current user location.")
            return
        }
        
        guard let title = titleTextView.text, let message = messageTextView.text else {
            // assert user interaction by text view delegate methods
            return
        }
        
        let communityMessageRequest = CommunityMessageRequest(title: title, time: Date(), message: message, location: location)
        
        communityBoard.postMessage(communityMessageRequest) { error in
            guard error == nil else {
                self.displayAlert(title: "Error", message: "Failed to post message: \(error!)")
                return
            }
            
            self.locationManager.stopPolling()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}

extension UIViewController {
    func displayAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
