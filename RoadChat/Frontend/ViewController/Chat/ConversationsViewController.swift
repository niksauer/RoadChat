//
//  ConversationsViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 02.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import CoreData

class ConversationsViewController: FetchedResultsTableViewController<Conversation> {
    
    // MARK: - Private Properties
    private let viewFactory: ViewControllerFactory
    private let user: User
    private let searchContext: NSManagedObjectContext
    private let cellDateFormatter: DateFormatter
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, user: User, searchContext: NSManagedObjectContext, cellDateFormatter: DateFormatter) {
        self.viewFactory = viewFactory
        self.user = user
        self.searchContext = searchContext
        self.cellDateFormatter = cellDateFormatter
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = "Chat"
        self.tabBarItem = UITabBarItem(title: "Chat", image: #imageLiteral(resourceName: "speech_buble_glyph"), tag: 2)
        self.navigationItem.leftBarButtonItem = editButtonItem
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "worldwide_location"), style: .plain, target: self, action: #selector(radarButtonPressed))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib.init(nibName: "ConversationCell", bundle: nil), forCellReuseIdentifier: "ConversationCell")
        
        // pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl?.layer.zPosition = -1
        refreshControl?.addTarget(self, action: #selector(updateData), for: .valueChanged)
        self.tableView.addSubview(refreshControl!)
        
        updateData()
        updateUI()
    }
    
    // MARK: - Private Methods
    @objc private func updateData() {
        user.getConversations { _ in
            self.refreshControl?.endRefreshing()
        }
    }
    
    private func updateUI() {
        let request: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        request.predicate = NSPredicate(format: "ANY participants.user.id = %d AND approvalStatus != %@", user.id, "deleted")
        request.sortDescriptors = [NSSortDescriptor(key: "newestMessage.time", ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController<Conversation>(fetchRequest: request, managedObjectContext: searchContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        try? fetchedResultsController.performFetch()
    }
    
    @objc private func radarButtonPressed() {
        guard user.privacy!.shareLocation else {
            displayAlert(title: "Warning", message: "Please enable location sharing in order to discover nearby users: \nProfile > Settings > Privacy > Location ", completion: nil)
            return
        }
        
        let radarViewController = viewFactory.makeRadarController(activeUser: user)
        let radarNavigationController = UINavigationController(rootViewController: radarViewController)
        self.present(radarNavigationController, animated: true, completion: nil)
    }
    
    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let conversation = fetchedResultsController.object(at: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as! ConversationCell
        cell.accessoryType = .disclosureIndicator
        cell.configure(conversation: conversation, activeUser: user, dateFormatter: cellDateFormatter)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversation = fetchedResultsController.object(at: indexPath)
        
        let conversationViewController = viewFactory.makeConversationViewController(for: conversation, activeUser: user)
        navigationController?.pushViewController(conversationViewController, animated: true)
    }
    
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let conversation = fetchedResultsController.object(at: indexPath)
            
            conversation.delete { error in
                guard error == nil else {
                    // present delete error
                    return
                }
            }
        default:
            return
        }
    }
    
}

