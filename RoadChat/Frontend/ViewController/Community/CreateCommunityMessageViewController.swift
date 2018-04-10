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
    @IBOutlet weak var titleWordCountLabel: UILabel!
    @IBOutlet weak var messageWordCountLabel: UILabel!
    var rightBarButtonItem: UIBarButtonItem!
    
    // MARK: - Private Properties
    private let communityBoard: CommunityBoard
    private let locationManager: LocationManager
    private var titleWordCount: Int = 0
    private var messageWordCount: Int = 0 
    
    
    // MARK: - Initialization
    init(communityBoard: CommunityBoard, locationManager: LocationManager) {
        self.communityBoard = communityBoard
        self.locationManager = locationManager
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = "New Post"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed(_:)))
        self.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .done, target: self, action: #selector(sendButtonPressed(_:)))
        self.rightBarButtonItem.isEnabled = false
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        messageTextView.delegate = self
        titleTextView.delegate = self
        messageWordCountLabel.text = "\(messageWordCount)/280"
        titleWordCountLabel.text = "\(titleWordCount)/140"
        locationManager.startPolling()
    }
    
    // MARK: - Public Methods
    
    func textViewDidChange(_ textView: UITextView) {
        
        if (textView == titleTextView) {
            titleWordCount = textView.text.count
            titleWordCountLabel.text = "\(titleWordCount)/140"
            
            if (textView.text.count > 1){
                rightBarButtonItem.isEnabled = true
            }
            
            if (textView.text.count > 140){
                rightBarButtonItem.isEnabled = false
            }
            
            
        }
        if (textView == messageTextView) {
            messageWordCount = textView.text.count
            messageWordCountLabel.text = "\(messageWordCount)/280"
            
            if (textView.text.count > 1){
                rightBarButtonItem.isEnabled = true
            }
            
            if (textView.text.count < 280){
                rightBarButtonItem.isEnabled = false
            }
            
        }
       
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
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
            if (textView.text.count < 140){
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
            displayAlarm(message: "Please Enter Text")
            return
        }
        
        let communityMessageRequest = CommunityMessageRequest(title: title, time: Date(), message: message, location: location)
        
        communityBoard.postMessage(communityMessageRequest) { error in
            guard error == nil else {
                self.displayAlarm(message: "Message could not be postet")
                return
            }
            
            self.locationManager.stopPolling()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
   
    
    private func displayAlarm(message: String) {
    let alertController = UIAlertController(title: "Error", message:
    message, preferredStyle: UIAlertControllerStyle.alert)
    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
    self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    
}
