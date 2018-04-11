//
//  TrafficMessagesViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 05.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import CoreData

class TrafficMessagesViewController: FetchedResultsCollectionViewController<TrafficMessage>, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Typealiases
    typealias ColorPalette = BasicColorPalette & TrafficMessageCell.ColorPalette
    
    // MARK: - Private Properties
    private let viewFactory: ViewControllerFactory
    private let trafficBoard: TrafficBoard
    private let user: User?
    private let searchContext: NSManagedObjectContext
    private let cellDateFormatter: DateFormatter
    private let colorPalette: ColorPalette
    
    private let reuseIdentifier = "TrafficMessageCell"
    private var sizingCell: TrafficMessageCell!
    
    private var refreshControl: UIRefreshControl?
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, trafficBoard: TrafficBoard, user: User?, searchContext: NSManagedObjectContext, cellDateFormatter: DateFormatter, colorPalette: ColorPalette) {
        self.viewFactory = viewFactory
        self.trafficBoard = trafficBoard
        self.user = user
        self.searchContext = searchContext
        self.cellDateFormatter = cellDateFormatter
        self.colorPalette = colorPalette
        
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        
        collectionView?.backgroundColor = colorPalette.backgroundColor
        collectionView?.alwaysBounceVertical = true
        
        sizingCell = {
            let nib = Bundle.main.loadNibNamed(reuseIdentifier, owner: self, options: nil)
            let sizingCell = nib?.first as! TrafficMessageCell
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
        trafficBoard.getMessages(completion: nil)
        updateUI()
    }
    
    // MARK: - Private Methods
    @objc private func updateData() {
        trafficBoard.getMessages { _ in
            self.refreshControl?.endRefreshing()
        }
    }
    
    private func updateUI() {
        let request: NSFetchRequest<TrafficMessage> = TrafficMessage.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "time", ascending: true)]
        
        if let user = user {
            request.predicate = NSPredicate(format: "senderID = %d", user.id)
        }
        
        fetchedResultsController = NSFetchedResultsController<TrafficMessage>(fetchRequest: request, managedObjectContext: searchContext, sectionNameKeyPath: nil, cacheName: "TrafficMessages")
        fetchedResultsController?.delegate = self
        
        try? fetchedResultsController?.performFetch()
        collectionView?.reloadData()
    }
    
    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = fetchedResultsController!.object(at: indexPath)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TrafficMessageCell
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
    
    // MARK: UICollectionViewDelegate
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
}

// MARK: - TrafficMessageCellDelegate
extension TrafficMessagesViewController: TrafficMessageCellDelegate {
    func trafficMessageCellDidPressUpvote(_ sender: TrafficMessageCell) {
        guard let indexPath = collectionView?.indexPath(for: sender) else {
            return
        }
        
        let message = fetchedResultsController!.object(at: indexPath)
        
        message.upvote { error in
            guard error == nil else {
                // handle error
                return
            }
            
            let cell = self.collectionView?.cellForItem(at: indexPath) as! TrafficMessageCell
            cell.karma = message.storedKarma
        }
    }
    
    func trafficMessageCellDidPressDownvote(_ sender: TrafficMessageCell) {
        guard let indexPath = collectionView?.indexPath(for: sender) else {
            return
        }
        
        let message = fetchedResultsController!.object(at: indexPath)
        
        message.downvote { error in
            guard error == nil else {
                // handle error
                return
            }
            
            let cell = self.collectionView?.cellForItem(at: indexPath) as! TrafficMessageCell
            cell.karma = message.storedKarma
        }
    }
}