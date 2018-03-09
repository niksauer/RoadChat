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

    
    let communityStore = CommunityStore()
    @IBOutlet weak var communityMessageTextArea: UITextView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func postButtonPressed(_ sender: Any) {
        let time = Date()
        guard let postText = communityMessageTextArea.text else {
            //handle missing fields error
            log.warning("Missing post text")
            return
        }
        
        let communityRequest = CommunityMessageRequest(time: time, message: postText, latitude: 100, longitude: 100, altitude: 100, horizontalAccuracy: 10, verticalAccuracy: 10, course: 10, speed: 10)
        communityStore.create(communityRequest) { error in
            guard error == nil else {
                //handle post error
                return
            }
            log.info("Successfull Post")
            
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.removeAnimate()
    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished)
            {
                self.view.removeFromSuperview()
            }
            log.info("Successfull Post")
            
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
