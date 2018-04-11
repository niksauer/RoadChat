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
    
    // MARK: - Typealiases
    typealias ColorPalette = BasicColorPalette
    
    // MARK: - Outlets
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var messageTextView: UITextView!
    
    @IBOutlet weak var titleCharacterCountLabel: UILabel!
    @IBOutlet weak var messageCharacterCountLabel: UILabel!
    @IBOutlet weak var messageCharacterCountLabelBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Private Properties
    private let communityBoard: CommunityBoard
    private let locationManager: LocationManager
    private let colorPalette: ColorPalette
    
    private var sendBarButtonItem: UIBarButtonItem!
    
    private let maxTitleCharacters = 140
    private let maxMessageCharacters = 280
    private let messageTextViewPlaceholder = "(Optional)"
    
    private var titleCharacterCount: Int = 0 {
        didSet {
            validateSendButton()
            titleCharacterCountLabel.text = "\(titleCharacterCount)/\(maxTitleCharacters)"
        }
    }
    
    private var messageCharacterCount: Int = 0 {
        didSet {
            validateSendButton()
            messageCharacterCountLabel.text = "\(messageCharacterCount)/\(maxMessageCharacters)"
        }
    }
    
    // MARK: - Initialization
    init(communityBoard: CommunityBoard, locationManager: LocationManager, colorPalette: ColorPalette) {
        self.communityBoard = communityBoard
        self.locationManager = locationManager
        self.colorPalette = colorPalette
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        locationManager.stopPolling()
    }
    
    // MARK: - Public Methods
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
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
        
        let communityMessageRequest = CommunityMessageRequest(title: title, time: Date(), message: messageCharacterCount > 0 ? message : "", location: location)
        
        communityBoard.postMessage(communityMessageRequest) { error in
            guard error == nil else {
                self.displayAlert(title: "Error", message: "Failed to post message: \(error!)")
                return
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    //MARK: -Keyboard
    @objc func keyboardWillShow(notification: Notification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        messageCharacterCountLabelBottomConstraint.constant = keyboardHeight + 8
    }
    
    @objc func keyboardWillHide(notification: Notification) {
       messageCharacterCountLabelBottomConstraint.constant = 8
    }
    
    // MARK: - Private Methods
    private func validateSendButton() {
        if messageCharacterCount > maxMessageCharacters {
            sendBarButtonItem.isEnabled = false
        } else {
            if titleCharacterCount < 1 {
                sendBarButtonItem.isEnabled = false
            } else if titleCharacterCount <= maxTitleCharacters {
                sendBarButtonItem.isEnabled = true
            } else {
                sendBarButtonItem.isEnabled = false
            }
        }
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == messageTextView, textView.text == messageTextViewPlaceholder {
            textView.text = ""
            textView.textColor = colorPalette.textColor
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == messageTextView, textView.text.count == 0 {
            textView.textColor = colorPalette.lightTextColor
            textView.text = messageTextViewPlaceholder
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == titleTextView {
            titleCharacterCount = textView.text.count
        }
        
        if textView == messageTextView {
            messageCharacterCount = textView.text.count
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.count == 1 {
            if textView == titleTextView {
                if textView.text.count < maxTitleCharacters {
                    return true
                } else {
                    return false
                }
            }
            
            if textView == messageTextView {
                if textView.text.count < maxMessageCharacters {
                    return true
                } else {
                    return false
                }
            }
        } else {
            // always allow backspace
            let char = text.cString(using: String.Encoding.utf8)!
            let isBackSpace = strcmp(char, "\\b")
            
            if isBackSpace == -92 {
                // backspace pressed
                return true
            } else {
                // pasted text
                if textView == titleTextView {
                    titleCharacterCount = textView.text.count
                }
                
                if textView == messageTextView {
                    messageCharacterCount = textView.text.count
                }
                
                return true
            }
        }
        
        return true
    }
    
}
