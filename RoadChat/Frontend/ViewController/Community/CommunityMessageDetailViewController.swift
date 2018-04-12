//
//  CommunityMessageViewController.swift
//  RoadChat
//
//  Created by Malcolm Malam on 11.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import RoadChatKit
import CoreLocation

class CommunityMessageDetailViewController: UIViewController {

    // MARK: - Typealiases
    typealias ColorPalette = KarmaColorPalette & BasicColorPalette
    
    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var upvotesImage: UIImageView!
    @IBOutlet weak var upvotesLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var downvoteButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!

    
    // MARK: - Private Properties
    private let viewFactory: ViewControllerFactory
    private let message: CommunityMessage
    private let sender: User
    private let activeUser: User
    private let dateFormatter: DateFormatter
    private let colorPalette: ColorPalette
  
    
    private var karma: KarmaType! {
        didSet {
            switch karma {
            case .upvote:
                upvoteButton.backgroundColor = colorPalette.upvoteBgColor
                upvoteButton.tintColor = colorPalette.upvoteTextColor
                
                downvoteButton.backgroundColor = colorPalette.neutralBgColor
                downvoteButton.tintColor = colorPalette.tintColor
                
                upvotesImage.image = UIImage(named: "up-arrow")
                upvotesImage.tintColor = colorPalette.upvoteBgColor
            case .neutral:
                upvoteButton.backgroundColor = colorPalette.neutralBgColor
                upvoteButton.tintColor = colorPalette.tintColor
                
                downvoteButton.backgroundColor = colorPalette.neutralBgColor
                downvoteButton.tintColor = colorPalette.tintColor
                
                upvotesImage.image = UIImage(named: "up-arrow")
                upvotesImage.tintColor = colorPalette.neutralTextColor
            case .downvote:
                upvoteButton.backgroundColor = colorPalette.neutralBgColor
                upvoteButton.tintColor = colorPalette.tintColor
                
                downvoteButton.backgroundColor = colorPalette.downvoteBgColor
                downvoteButton.tintColor = colorPalette.downvoteTextColor
                
                upvotesImage.image = UIImage(named: "down-arrow")
                upvotesImage.tintColor = colorPalette.downvoteBgColor
            default:
                break
            }
        }
    }
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, message: CommunityMessage, sender: User, activeUser: User, dateFormatter: DateFormatter, colorPalette: ColorPalette) {
        self.viewFactory = viewFactory
        self.message = message
        self.sender = sender
        self.activeUser = activeUser
        self.dateFormatter = dateFormatter
        self.colorPalette = colorPalette
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        titleLabel.text = message.title
        messageLabel.text = message.message
        usernameLabel.text = String(sender.username!)
        upvotesLabel.text = String(message.upvotes)
        timeLabel.text = dateFormatter.string(from: message.time!)
        
        karma = message.storedKarma

        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        mapView.setCenter(location.coordinate, animated: true)
        mapView.addAnnotation(annotation)
        
        let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        mapView.setRegion(region, animated: true)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.expandMap (_:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        mapView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    // MARK: - Public Methods
    @objc func expandMap(_ sender: UITapGestureRecognizer) {
       
        if sender.state == .ended {
            let location = CLLocation(location: message.location!)
            let locationViewContoller = viewFactory.makeLocationViewController(for: location)
            self.navigationController?.pushViewController(locationViewContoller, animated: true)
        }
        
    }
    
    @IBAction func didPressUpvoteButton(_ sender: UIButton) {
        message.upvote { error in
            guard error == nil else {
                // handle error
                return
            }
            
            self.karma = self.message.storedKarma
            self.upvotesLabel.text = String(self.message.upvotes)
        }
    }
    
    @IBAction func didPressDownvoteButton(_ sender: UIButton) {
        message.downvote { error in
            guard error == nil else {
                // handle error
                return
            }
            
            self.karma = self.message.storedKarma
            self.upvotesLabel.text = String(self.message.upvotes)
        }
    }
    
    @IBAction func didPressLocationButton(_ sender: UIButton) {
        let location = CLLocation(location: message.location!)
        let locationViewContoller = viewFactory.makeLocationViewController(for: location)
        self.navigationController?.pushViewController(locationViewContoller, animated: true)
    }
    
    @IBAction func didPressProfileButton(_ sender: UIButton) {
        let profileViewController = viewFactory.makeProfileViewController(for: self.sender)
        profileViewController.showsSenderProfile = true
        self.navigationController?.pushViewController(profileViewController, animated: true)
    }
    
    @IBAction func didPressSettingsButton(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let flagAction = UIAlertAction(title: "Flag", style: .default, handler: { _ in
            log.debug("post flagged")
            self.dismiss(animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        })
        
        actionSheet.addAction(cancelAction)
        actionSheet.addAction(flagAction)
        
        if message.senderID == activeUser.id {
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                self.message.delete { error in
                    guard error == nil else {
                        //handle delete error
                        return
                    }
                }
                
                self.navigationController?.popViewController(animated: true)
            })
            
            actionSheet.addAction(deleteAction)
        }
        
        self.navigationController?.present(actionSheet, animated: true, completion: nil)
    }
    
}
