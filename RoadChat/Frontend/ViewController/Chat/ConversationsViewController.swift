//
//  ConversationsViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 02.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import CoreData

class ConversationsViewController: FetchedResultsTableViewController {
    
    // MARK: - Private Properties
    private let viewFactory: ViewControllerFactory
    private let user: User
    private let searchContext: NSManagedObjectContext
    private let cellDateFormatter: DateFormatter

    private var fetchedResultsController: NSFetchedResultsController<Conversation>?
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, user: User, searchContext: NSManagedObjectContext, cellDateFormatter: DateFormatter) {
        self.viewFactory = viewFactory
        self.user = user
        self.searchContext = searchContext
        self.cellDateFormatter = cellDateFormatter
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = "Chat"
        self.tabBarItem = UITabBarItem(title: "Chat", image: #imageLiteral(resourceName: "speech_buble_glyph"), tag: 2)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "create_new_glyph"), style: .plain, target: nil, action: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib.init(nibName: "ConversationCell", bundle: nil), forCellReuseIdentifier: "ConversationCell")
        updateUI()
    }
    
    // MARK: - Private Methods
    private func updateUI() {
        let request: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        request.predicate = NSPredicate(format: "user.id = %d", user.id)
        request.sortDescriptors = [NSSortDescriptor(key: "lastChange", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController<Conversation>(fetchRequest: request, managedObjectContext: searchContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        try? fetchedResultsController?.performFetch()
        
        tableView.reloadData()
    }
    
    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let conversation = fetchedResultsController!.object(at: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as! ConversationCell
        cell.configure(conversation: conversation, newestMessage: conversation.newestMessage, dateFormatter: cellDateFormatter)
        
        return cell
    }
    
}

// MARK: - Table View Data Source
extension ConversationsViewController {
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

