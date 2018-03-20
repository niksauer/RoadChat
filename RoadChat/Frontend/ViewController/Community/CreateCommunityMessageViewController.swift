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
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textView: UITextView!
    
    // MARK: - Public Properties
    typealias Factory = ViewControllerFactory & CommunityBoardFactory
    
    // MARK: - Private Properties
    private var factory: Factory!
    private lazy var communityBoard = factory.makeCommunityBoard()
    
    // MARK: - Initialization
    class func instantiate(factory: Factory) -> CreateCommunityMessageViewController {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateCommunityMessageViewController") as! CreateCommunityMessageViewController
        controller.factory = factory
        return controller
    }
    
    // MARK: - Public Methods
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        guard let _ = textField.text, let message = textView.text else {
            // handle missing fields error
            log.warning("Empty message content.")
            return
        }
        
        let communityMessageRequest = CommunityMessageRequest(time: Date(), message: message, latitude: 100, longitude: 100, altitude: 100, horizontalAccuracy: 10, verticalAccuracy: 10, course: 10, speed: 10)
        
        communityBoard.postMessage(communityMessageRequest) { error in
            guard error == nil else {
                // handle post error
                return
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

}
