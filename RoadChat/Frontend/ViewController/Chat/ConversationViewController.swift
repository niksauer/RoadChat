//
//  ConversationViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 16.05.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import RoadChatKit

class ConversationViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Typealiases
    typealias ColorPalette = BasicColorPalette
    
    // MARK: - Outlets
    @IBOutlet weak var messagesContainer: UIView!
    @IBOutlet weak var inputContainer: UIView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    // MARK: - Constraints
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    // MARK: - Private Properties
    private let viewFactory: ViewControllerFactory
    private let conversation: Conversation
    private let activeUser: User
    private let colorPalette: ColorPalette
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, conversation: Conversation, activeUser: User, colorPalette: ColorPalette) {
        self.viewFactory = viewFactory
        self.conversation = conversation
        self.activeUser = activeUser
        self.colorPalette = colorPalette
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = conversation.title
        hidesBottomBarWhenPushed = true
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "profile_glyph"), style: .plain, target: self, action: #selector(didPressProfileButton))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // keyboard notification
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        // messages view controller
        let directMessagesViewController = viewFactory.makeDirectMessagesViewController(for: conversation, activeUser: activeUser)
        addChildViewController(directMessagesViewController)
        messagesContainer.addSubview(directMessagesViewController.view)
        directMessagesViewController.didMove(toParentViewController: self)
        directMessagesViewController.view.translatesAutoresizingMaskIntoConstraints = false
        directMessagesViewController.view.pin(to: messagesContainer)
        
        // additional view setup
        inputContainer.backgroundColor = colorPalette.controlColor
        sendButton.isEnabled = false
        messageTextField.delegate = self
        messageTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        // enable keyboard dismissal
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        directMessagesViewController.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // MARK: - Public Methods
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func didPressSendButton(_ sender: UIButton) {
        guard let message = messageTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), message.count >= 1 else {
            return
        }
    
        let request = DirectMessageRequest(time: Date(), message: message)
        
        conversation.createMessage(request) { error in
            guard error == nil else {
                // handle error
                return
            }
            
            self.messageTextField.text = nil
        }
    }
    
    // MARK: - TextFieldDelegate
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let message = messageTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), message.count >= 1 {
            sendButton.isEnabled = true
        } else {
            sendButton.isEnabled = false
        }
    }
    
    // MARK: - Keyboard Notifications
    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo! as NSDictionary
        let keyboardFrame = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        topConstraint.constant = -48 - keyboardHeight + view.safeAreaInsets.bottom
        bottomConstraint.constant = -keyboardHeight
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        topConstraint.constant = -48
        bottomConstraint.constant = 0
    }
    
    // MARK: - Private Methods
//    @objc private func didPressProfileButton() {
//        let profileViewController = viewFactory.makeProfileViewController(for: conv, activeUser: activeUser)
//        navigationController?.pushViewController(profileViewController, animated: true)
//    }

}
