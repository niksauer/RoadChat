//
//  PopUpCommunityPostViewController.swift
//  RoadChat
//
//  Created by Malcolm Malam on 09.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import RoadChatKit

class PopUpCommunityPostViewController: UIViewController {
    
    // MARK: - Public Properties
    let communityBoard = CommunityBoard()
    
    // MARK: - Outlets
    @IBOutlet weak var communityMessageTextArea: UITextView!
    
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    // MARK: - Public Methods
    @IBAction func postButtonPressed(_ sender: Any) {
        let time = Date()
        guard let postText = communityMessageTextArea.text else {
            //handle missing fields error
            log.warning("Missing post text")
            return
        }
        
        let communityMessageRequest = CommunityMessageRequest(time: time, message: postText, latitude: 100, longitude: 100, altitude: 100, horizontalAccuracy: 10, verticalAccuracy: 10, course: 10, speed: 10)
        communityBoard.postMessage(communityMessageRequest) { error in
            guard error == nil else {
                //handle post error
                return
            }
            log.info("Successfull Post")
            
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
