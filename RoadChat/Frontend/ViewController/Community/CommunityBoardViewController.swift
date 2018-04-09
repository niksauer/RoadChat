//
//  CommunityBoardViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 01.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import CoreData

class CommunityBoardViewController: FetchedResultsTableViewController, CommunityMessageCellDelegate {
    
    // MARK: - Private Properties
    private let viewFactory: ViewControllerFactory
    private let communityBoard: CommunityBoard
    private let searchContext: NSManagedObjectContext
    private let cellDateFormatter: DateFormatter
    
    private var fetchedResultsController: NSFetchedResultsController<CommunityMessage>?
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, communityBoard: CommunityBoard, searchContext: NSManagedObjectContext, cellDateFormatter: DateFormatter) {
        self.viewFactory = viewFactory
        self.communityBoard = communityBoard
        self.searchContext = searchContext
        self.cellDateFormatter = cellDateFormatter
        
        super.init(nibName: nil, bundle: nil)
        self.title = "CommunityBoard"
        self.tabBarItem = UITabBarItem(title: "Community", image: #imageLiteral(resourceName: "collaboration"), tag: 0)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "create_new"), style: .plain, target: self, action: #selector(createButtonPressed(_:)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib.init(nibName: "CommunityMessageCell", bundle: nil), forCellReuseIdentifier: "CommunityMessageCell")
        communityBoard.getMessages(completion: nil)
        updateUI()
    }
    
    // MARK: - Private Methods
    private func updateUI() {
        let request: NSFetchRequest<CommunityMessage> = CommunityMessage.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "time", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController<CommunityMessage>(fetchRequest: request, managedObjectContext: searchContext, sectionNameKeyPath: nil, cacheName: "CommunityMessages")
        fetchedResultsController?.delegate = self
        try? fetchedResultsController?.performFetch()
        
        tableView.reloadData()
    }
    // MARK: - Public Methods
    @objc func createButtonPressed(_ sender: UIBarButtonItem) {
        let createMessageViewController = viewFactory.makeCreateCommunityMessageViewController()
        let createMessageNavigationController = UINavigationController(rootViewController: createMessageViewController)
        present(createMessageNavigationController, animated: true, completion: nil)
    }
    
    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = fetchedResultsController!.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommunityMessageCell", for: indexPath) as! CommunityMessageCell
        cell.delegate = self
        cell.configure(message: message, dateFormatter: cellDateFormatter)
        
        return cell
    }
    
    // MARK: - CommunityMessageCellDelegate Protocol
    func communityMessageCellDidPressUpvote(_ sender: CommunityMessageCell) {
        guard let indexPath = tableView.indexPath(for: sender) else {
            return
        }
        
        let message = fetchedResultsController!.object(at: indexPath)
        
        message.upvote { error in
            guard error == nil else {
                // handle error
                return
            }
            
            let cell = self.tableView.cellForRow(at: indexPath) as! CommunityMessageCell
            cell.karma = message.storedKarma
        }
    }

    func communityMessageCellDidPressDownvote(_ sender: CommunityMessageCell) {
        guard let indexPath = tableView.indexPath(for: sender) else {
            return
        }
        
        let message = fetchedResultsController!.object(at: indexPath)
        
        message.downvote { error in
            guard error == nil else {
                // handle error
                return
            }
            
            let cell = self.tableView.cellForRow(at: indexPath) as! CommunityMessageCell
            cell.karma = message.storedKarma
        }
    }
    
}

// MARK: - Table View Data Source
extension CommunityBoardViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].name
        } else {
            return nil
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return fetchedResultsController?.sectionIndexTitles
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return fetchedResultsController?.section(forSectionIndexTitle: title, at: index) ?? 0
    }
}
