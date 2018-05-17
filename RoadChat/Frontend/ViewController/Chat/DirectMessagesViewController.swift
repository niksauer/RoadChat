//
//  DirectMessagesViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 17.05.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import CoreData

class DirectMessagesViewController: FetchedResultsCollectionViewController<DirectMessage>, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Typealiases
    typealias ColorPalette = BasicColorPalette
    
    // MARK: - Private Properties
    private let viewFactory: ViewControllerFactory
    private let conversation: Conversation
    private let activeUser: User
    private let searchContext: NSManagedObjectContext
    private let cellDateFormatter: DateFormatter
    private let colorPalette: ColorPalette
    
    private let reuseIdentifier = "DirectMessageCell"
//    private var sizingCell: DirectMessageCell!
    
    private var refreshControl: UIRefreshControl?
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, conversation: Conversation, activeUser: User, searchContext: NSManagedObjectContext, cellDateFormatter: DateFormatter, colorPalette: ColorPalette) {
        self.viewFactory = viewFactory
        self.conversation = conversation
        self.activeUser = activeUser
        self.searchContext = searchContext
        self.cellDateFormatter = cellDateFormatter
        self.colorPalette = colorPalette
        
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        
        self.title = conversation.title
        
        collectionView?.backgroundColor = colorPalette.contentBackgroundColor
        collectionView?.alwaysBounceVertical = true
        
//        sizingCell = {
//            let nib = Bundle.main.loadNibNamed(reuseIdentifier, owner: self, options: nil)
//            let sizingCell = nib?.first as! DirectMessageCell
//            return sizingCell
//        }()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register cell classes
        collectionView?.register(DirectMessageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl?.layer.zPosition = -1
        refreshControl?.addTarget(self, action: #selector(updateData), for: .valueChanged)
        self.collectionView?.addSubview(refreshControl!)
        
        // aditional view setup
        conversation.getMessages(completion: nil)
        updateUI()
    }
    
    // MARK: - Private Methods
    @objc private func updateData() {
        conversation.getMessages { _ in
            self.refreshControl?.endRefreshing()
        }
    }
    
    private func updateUI() {
        let request: NSFetchRequest<DirectMessage> = DirectMessage.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "time", ascending: true)]
        request.predicate = NSPredicate(format: "conversation.id = %d", conversation.id)
        
        fetchedResultsController = NSFetchedResultsController<DirectMessage>(fetchRequest: request, managedObjectContext: searchContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        
        try? fetchedResultsController?.performFetch()
        collectionView?.reloadData()
    }
    
    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = fetchedResultsController!.object(at: indexPath)
        let messageText = message.message!
        
        // deque cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DirectMessageCell
        cell.messageTextView.text = messageText
        
        // calculate size
        let size = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [.font : UIFont.systemFont(ofSize: 18)], context: nil)
    
        // adjust cell
        if message.senderID == activeUser.id {
            // incoming message
            cell.messageTextView.frame = CGRect(x: 8 + 8 + 10, y: 6, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
            cell.textBubbleView.frame = CGRect(x: 8, y: 0, width: estimatedFrame.width + 16 + 16 + 10, height: estimatedFrame.height + 20 + 8)
            
            cell.messageTextView.textColor = UIColor.black
            cell.bubbleImageView.tintColor = UIColor(white: 0.95, alpha: 1)
            cell.bubbleImageView.image = DirectMessageCell.leftBubble
//            cell.textBubbleView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        } else {
            // outgoing message
            cell.messageTextView.frame = CGRect(x: collectionView.frame.width - estimatedFrame.width - 16 - 8 - 8 - 4, y: 5, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
            cell.textBubbleView.frame = CGRect(x: collectionView.frame.width - estimatedFrame.width - 16 - 8 - 10 - 8 - 4, y: 0, width: estimatedFrame.width + 16 + 16 + 10, height: estimatedFrame.height + 20 + 8)
            
            cell.messageTextView.textColor = UIColor.white
            cell.bubbleImageView.tintColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
            cell.bubbleImageView.image = DirectMessageCell.rightBubble
//            cell.textBubbleView.backgroundColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // item for which size should be calculated
        let message = fetchedResultsController!.object(at: indexPath)
        let messageText = message.message!
        
        // width cell should use
        let width = collectionView.frame.width
        
        // calculate size based on sizing cell
        let size = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [.font : UIFont.systemFont(ofSize: 18)], context: nil)
        
        return CGSize(width: width, height: estimatedFrame.height + 20)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
    }

}

