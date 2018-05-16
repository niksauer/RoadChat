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
import MapKit

class CommunityMessageDetailViewController: UIViewController {

    // MARK: - Typealiases
    typealias ColorPalette = KarmaColorPalette & BasicColorPalette
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var upvotesImage: UIImageView!
    @IBOutlet weak var upvotesLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var downvoteButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
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
        if activeUser.id != sender.id {
            moreButton.isHidden = true
        }
        
        titleLabel.text = message.title
        messageLabel.text = message.message
        usernameLabel.text = String(sender.username!)
        upvotesLabel.text = String(message.upvotes)
        timeLabel.text = dateFormatter.string(from: message.time!)
        
        karma = message.storedKarma

        let location = message.storedLocation
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        mapView.setCenter(location.coordinate, animated: true)
        mapView.addAnnotation(annotation)
        
        let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        mapView.setRegion(region, animated: true)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.expandMap (_:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        mapView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        mapView.setCenter(message.storedLocation.coordinate, animated: true)
    }
    
    // MARK: - Public Methods
    @objc func expandMap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let locationViewContoller = viewFactory.makeLocationViewController(for: message.storedLocation)
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
        let locationViewContoller = viewFactory.makeLocationViewController(for: message.storedLocation)
        self.navigationController?.pushViewController(locationViewContoller, animated: true)
    }
    
    @IBAction func didPressProfileButton(_ sender: UIButton) {        
        let profileViewController = viewFactory.makeProfileViewController(for: self.sender, activeUser: activeUser)
        profileViewController.showsPublicProfile = true
        self.navigationController?.pushViewController(profileViewController, animated: true)
    }
    
    @IBAction func didPressSettingsButton(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        })
        
        actionSheet.addAction(cancelAction)
        
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
