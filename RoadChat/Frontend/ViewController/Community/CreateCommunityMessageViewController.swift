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
    
    // MARK: - Initialization
    init(communityBoard: CommunityBoard) {
        self.communityBoard = communityBoard
        
        super.init(nibName: nil, bundle: nil)
        self.title = "New Post"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed(_:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(postButtonPressed(_:)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    @IBAction func postButtonPressed(_ sender: UIButton) {
        guard let title = titleTextField.text, let message = messageTextView.text else {
            // handle missing fields error
            log.warning("Empty message content.")
            return
        }
        
        let communityMessageRequest = CommunityMessageRequest(title: title, time: Date(), message: message, latitude: 100, longitude: 100, altitude: 100, horizontalAccuracy: 10, verticalAccuracy: 10, course: 10, speed: 10)
        
        communityBoard.postMessage(communityMessageRequest) { error in
            guard error == nil else {
                // handle post error
                return
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}
