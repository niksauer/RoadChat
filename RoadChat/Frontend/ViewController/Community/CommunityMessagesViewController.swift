//
//  CommunityMessagesController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 09.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import CoreData

class CommunityMessagesViewController: UICollectionViewController {

    // MARK: - Private Properties
    private let viewFactory: ViewControllerFactory
    private let communityBoard: CommunityBoard
    private let user: User?
    private let searchContext: NSManagedObjectContext
    private let cellDateFormatter: DateFormatter
    
    private let reuseIdentifier = "CommunityMessageCell"
    private let backgroundColor = UIColor(red: 243/255, green: 242/255, blue: 247/255, alpha: 1)
    
    private var fetchedResultsController: NSFetchedResultsController<CommunityMessage>?
    private var blockOperations = [BlockOperation]()
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, communityBoard: CommunityBoard, user: User?, searchContext: NSManagedObjectContext, cellDateFormatter: DateFormatter) {
        self.viewFactory = viewFactory
        self.communityBoard = communityBoard
        self.user = user
        self.searchContext = searchContext
        self.cellDateFormatter = cellDateFormatter
        
        let layout = UICollectionViewFlowLayout()
//        layout.estimatedItemSize = CGSize(width: 1, height: 1)
        super.init(collectionViewLayout: layout)
        
        collectionView?.backgroundColor = backgroundColor
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(UINib.init(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        
        // TODO: -> move to seperate CommunityBoardViewController class
        tabBarItem = UITabBarItem(title: "Community", image: #imageLiteral(resourceName: "collaboration"), tag: 0)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "create_new"), style: .plain, target: self, action: #selector(createButtonPressed(_:)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    // MARK: - Public Methods
    @objc func createButtonPressed(_ sender: UIBarButtonItem) {
        let createMessageViewController = viewFactory.makeCreateCommunityMessageViewController()
        let createMessageNavigationController = UINavigationController(rootViewController: createMessageViewController)
        present(createMessageNavigationController, animated: true, completion: nil)
    }
    
    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = fetchedResultsController!.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CommunityMessageCell
        
        cell.delegate = self
//        cell.setWidth(view.frame.width)
        cell.configure(message: message, dateFormatter: cellDateFormatter)

        return cell
    }
    
    // MARK: UICollectionViewDelegate
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

// MARK: UICollectionViewDataSource
extension CommunityMessagesViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension CommunityMessagesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 120)
    }
}

// MARK: - FetchedResultsControllerDelegate
extension CommunityMessagesViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            blockOperations.append(BlockOperation {
                self.collectionView?.insertItems(at: [newIndexPath!])
            })
        case .delete:
            blockOperations.append(BlockOperation {
                self.collectionView?.deleteItems(at: [indexPath!])
            })
        case .update:
            blockOperations.append(BlockOperation {
                self.collectionView?.reloadItems(at: [indexPath!])
            })
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.performBatchUpdates({
            for operation in self.blockOperations {
                operation.start()
            }
        }, completion: { completed in
//            let lastItem = self.fetchedResultsController!.sections![0].numberOfObjects - 1
//            let indexPath = IndexPath(item: lastItem, section: 0)
//            self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
        })
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
