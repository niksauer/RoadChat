//
//  CreateTrafficMessageController.swift
//  RoadChat
//
//  Created by Phillip Rust on 07.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import RoadChatKit

class CreateTrafficMessageViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - Typealiases
    typealias ColorPalette = BasicColorPalette
    
    // MARK: - Views
    private let typePickerView = UIPickerView()
    private var sendBarButtonItem: UIBarButtonItem!
    
    // MARK: - Outlets
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var typeTextField: UITextField!
    
    @IBOutlet weak var messageCharacterCountLabel: UILabel!
    @IBOutlet weak var messageCharacterCountLabelBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Private Properties
    private let trafficBoard: TrafficBoard
    private let locationManager: LocationManager
    private let colorPalette: ColorPalette

    private let maxTitleCharacters = 140
    private let maxMessageCharacters = 280
    private let messageTextViewPlaceholder = "(Optional)"
    
    private var messageCharacterCount: Int = 0 {
        didSet {
            validateSendButton()
            messageCharacterCountLabel.text = "\(messageCharacterCount)/\(maxMessageCharacters)"
        }
    }
    
    // MARK: - Initialization
    init(trafficBoard: TrafficBoard, locationManager: LocationManager, colorPalette: ColorPalette) {
        self.trafficBoard = trafficBoard
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
        typePickerView.delegate = self
        
        typeTextField.inputView = typePickerView
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        messageCharacterCount = 0
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Methods
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        guard let coreLocation = locationManager.lastLocation else {
            log.warning("Failed to retrieve current user location.")
            return
        }
        
        guard let type = typeTextField.text, let message = messageTextView.text else {
            // assert user interaction by text view delegate methods
            return
        }
        
        let location = RoadChatKit.Location(coreLocation: coreLocation)
        
        guard let trafficType = TrafficType(rawValue: type.lowercased()) else {
            return
        }
        
        let trafficMessageRequest = TrafficMessageRequest(type: trafficType, time: Date(), message: messageCharacterCount > 0 ? message : "", location: location)
        
        trafficBoard.postMessage(trafficMessageRequest) { error in
            guard error == nil else {
                self.displayAlert(title: "Error", message: "Failed to post message: \(error!)")
                return
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Private Methods
    private func validateSendButton() {
        if messageCharacterCount > maxMessageCharacters {
            sendBarButtonItem.isEnabled = false
        } else if let _ = TrafficType(rawValue: typeTextField.text!.lowercased()) {
            sendBarButtonItem.isEnabled = true
        } else {
            sendBarButtonItem.isEnabled = false
        }
    }
    
    // MARK: - Keyboard Notifications
    @objc func keyboardWillShow(notification: Notification) {
        let userInfo = notification.userInfo! as NSDictionary
        let keyboardFrame = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        messageCharacterCountLabelBottomConstraint.constant = keyboardHeight - 16
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        messageCharacterCountLabelBottomConstraint.constant = 8
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
        if textView == messageTextView {
            messageCharacterCount = textView.text.count
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.count == 1 {
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
                
                if textView == messageTextView {
                    messageCharacterCount = textView.text.count
                }
                
                return true
            }
        }
        
        return true
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return TrafficType.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return TrafficType.allCases[row].rawValue.capitalized
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        typeTextField.text = TrafficType.allCases[row].rawValue.capitalized
        validateSendButton()
        self.view.endEditing(true)
    }

}


