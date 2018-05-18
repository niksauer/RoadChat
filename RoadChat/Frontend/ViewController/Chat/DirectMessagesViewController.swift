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
    typealias ColorPalette = BasicColorPalette & ChatColorPalette
    
    // MARK: - Private Properties
    private let viewFactory: ViewControllerFactory
    private let conversation: Conversation
    private let activeUser: User
    private let searchContext: NSManagedObjectContext
    private let cellDateFormatter: DateFormatter
    private let colorPalette: ColorPalette
    
    private let reuseIdentifier = "DirectMessageCell"
    private var sizingCell = DirectMessageCell()
    
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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DirectMessageCell
        cell.configure(message: message, activeUserID: Int(activeUser.id), colorPalette: colorPalette)
        
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // item for which size should be calculated
        let message = fetchedResultsController!.object(at: indexPath)
        
        // width cell should use
        let width = collectionView.frame.width
        
        // configure sizing cell
        sizingCell.configure(message: message, activeUserID: Int(activeUser.id), colorPalette: colorPalette)
        
        // calculate size based on sizing cell
        return sizingCell.preferredLayoutSizeFittingWidth(width)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 0, bottom: 12, right: 0)
    }

}

