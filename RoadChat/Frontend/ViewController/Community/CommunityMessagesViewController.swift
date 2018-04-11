//
//  CommunityMessagesController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 09.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import CoreData

class CommunityMessagesViewController: FetchedResultsCollectionViewController<CommunityMessage>, UICollectionViewDelegateFlowLayout {

    // MARK: - Typealiases
    typealias ColorPalette = BasicColorPalette & TrafficMessageCell.ColorPalette
    
    // MARK: - Private Properties
    private let viewFactory: ViewControllerFactory
    private let communityBoard: CommunityBoard
    private let sender: User?
    private let activeUser: User
    private let searchContext: NSManagedObjectContext
    private let cellDateFormatter: DateFormatter
    private let colorPalette: ColorPalette
    private let userManager: UserManager
    
    private let reuseIdentifier = "CommunityMessageCell"
    private var sizingCell: CommunityMessageCell!
    
    private var refreshControl: UIRefreshControl?
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, communityBoard: CommunityBoard, sender: User?, activeUser: User, searchContext: NSManagedObjectContext, cellDateFormatter: DateFormatter, colorPalette: ColorPalette, userManager: UserManager) {
        self.viewFactory = viewFactory
        self.communityBoard = communityBoard
        self.sender = sender
        self.activeUser = activeUser
        self.searchContext = searchContext
        self.cellDateFormatter = cellDateFormatter
        self.colorPalette = colorPalette
        self.userManager = userManager
        
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        
        collectionView?.backgroundColor = colorPalette.backgroundColor
        collectionView?.alwaysBounceVertical = true
        
        sizingCell = {
            let nib = Bundle.main.loadNibNamed(reuseIdentifier, owner: self, options: nil)
            let sizingCell = nib?.first as! CommunityMessageCell
            sizingCell.colorPalette = colorPalette
            return sizingCell
        }()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register cell classes
        collectionView?.register(UINib.init(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        
        // pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl?.layer.zPosition = -1
        refreshControl?.addTarget(self, action: #selector(updateData), for: .valueChanged)
        self.collectionView?.addSubview(refreshControl!)
        
        // aditional view setup
        communityBoard.getMessages(completion: nil)
        updateUI()
    }
    
    // MARK: - Private Methods
    @objc private func updateData() {
        communityBoard.getMessages { _ in
            self.refreshControl?.endRefreshing()
        }
    }
    
    private func updateUI() {
        let request: NSFetchRequest<CommunityMessage> = CommunityMessage.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "time", ascending: true)]
        
        if let user = sender {
            request.predicate = NSPredicate(format: "senderID = %d", user.id)
        }
        
        fetchedResultsController = NSFetchedResultsController<CommunityMessage>(fetchRequest: request, managedObjectContext: searchContext, sectionNameKeyPath: nil, cacheName: "CommunityMessages")
        fetchedResultsController?.delegate = self
        
        try? fetchedResultsController?.performFetch()
        collectionView?.reloadData()
    }
    
    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = fetchedResultsController!.object(at: indexPath)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CommunityMessageCell
        cell.delegate = self
        cell.configure(message: message, dateFormatter: cellDateFormatter, colorPalette: colorPalette)
        
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // item for which size should be calculated
        let message = fetchedResultsController!.object(at: indexPath)
        
        // width cell should use
        let width = collectionView.frame.width
    
        // configure sizing cell
        sizingCell.configure(message: message, dateFormatter: cellDateFormatter, colorPalette: colorPalette)
        
        // calculate size based on sizing cell
        return sizingCell.preferredLayoutSizeFittingWidth(width)
    }
    
    //MARK: - UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let message = fetchedResultsController!.object(at: indexPath)
        
        if let sender = userManager.findUserById(Int(message.senderID), context: searchContext) {
            message.user = sender
            let detailMessageViewController = self.viewFactory.makeCommunityMessageDetailViewController(for: message, sender: sender, activeUser: user)
            self.navigationController?.pushViewController(detailMessageViewController, animated: true)
        } else {
            userManager.getUserById(Int(message.senderID)) { user, error in
                guard let sender = user else {
                    //handle failed user request error
                    self.displayAlert(title: "Error", message: "Failed to retrieve sender: \(error!)")
                    return
                }
                message.user = sender
                let detailMessageViewController = self.viewFactory.makeCommunityMessageDetailViewController(for: message, sender: sender, activeUser: user)
                self.navigationController?.pushViewController(detailMessageViewController, animated: true)
            }
        }
    }

}

// MARK: - CommunityMessageCellDelegate
extension CommunityMessagesViewController: CommunityMessageCellDelegate {
    func communityMessageCellDidPressUpvote(_ sender: CommunityMessageCell) {
        guard let indexPath = collectionView?.indexPath(for: sender) else {
            return
        }
        
        let message = fetchedResultsController!.object(at: indexPath)
    
        message.upvote { error in
            guard error == nil else {
                // handle error
                return
            }
            
            let cell = self.collectionView?.cellForItem(at: indexPath) as! CommunityMessageCell
            cell.karma = message.storedKarma
        }
    }
    
    func communityMessageCellDidPressDownvote(_ sender: CommunityMessageCell) {
        guard let indexPath = collectionView?.indexPath(for: sender) else {
            return
        }
        
        let message = fetchedResultsController!.object(at: indexPath)
        
        message.downvote { error in
            guard error == nil else {
                // handle error
                return
            }
            
            let cell = self.collectionView?.cellForItem(at: indexPath) as! CommunityMessageCell
            cell.karma = message.storedKarma
        }
    }
    
   
}
