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

    // MARK: - Private Properties
    private let viewFactory: ViewControllerFactory
    private let communityBoard: CommunityBoard
    private let user: User?
    private let searchContext: NSManagedObjectContext
    private let cellDateFormatter: DateFormatter
    private let karmaColorPalette: KarmaColorPalette
    
    private let reuseIdentifier = "CommunityMessageCell"
    private let backgroundColor = UIColor(red: 243/255, green: 242/255, blue: 247/255, alpha: 1)
    
    private var sizingCell: CommunityMessageCell!
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, communityBoard: CommunityBoard, user: User?, searchContext: NSManagedObjectContext, cellDateFormatter: DateFormatter, karmaColorPalette: KarmaColorPalette) {
        self.viewFactory = viewFactory
        self.communityBoard = communityBoard
        self.user = user
        self.searchContext = searchContext
        self.cellDateFormatter = cellDateFormatter
        self.karmaColorPalette = karmaColorPalette
    
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        
        collectionView?.backgroundColor = backgroundColor
        collectionView?.alwaysBounceVertical = true
        
        sizingCell = {
            let nib = Bundle.main.loadNibNamed(reuseIdentifier, owner: self, options: nil)
            let sizingCell = nib?.first as! CommunityMessageCell
            sizingCell.colorPalette = karmaColorPalette
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
        
        // aditional view setup
        communityBoard.getMessages(completion: nil)
        updateUI()
    }
    
    // MARK: - Private Methods
    private func updateUI() {
        let request: NSFetchRequest<CommunityMessage> = CommunityMessage.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "time", ascending: true)]
        
        if let user = user {
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
        cell.colorPalette = karmaColorPalette
        cell.configure(message: message, dateFormatter: cellDateFormatter)
        
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // item for which size should be calculated
        let message = fetchedResultsController!.object(at: indexPath)
        
        // width cell should use
        let width = collectionView.frame.width
    
        // configure sizing cell
        sizingCell.configure(message: message, dateFormatter: cellDateFormatter)
        
        // calculate size based on sizing cell
        return sizingCell.preferredLayoutSizeFittingWidth(width)
    }
    
    // MARK: UICollectionViewDelegate
    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

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
