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
    
    // MARK: - Public Properties
    typealias Factory = ViewControllerFactory & AuthenticationManagerFactory
    
    // MARK: - Private Properties
    private var user: User!
    private var factory: Factory!
    
    private var fetchedResultsController: NSFetchedResultsController<Conversation>?
    
    // MARK: - Initialization
    class func instantiate(factory: Factory, user: User) -> ConversationsViewController {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ConversationsViewController") as! ConversationsViewController
        controller.factory = factory
        controller.user = user
        return controller
    }

    override func viewDidLoad() {
        updateUI()
    }
    
    // MARK: - Private Methods
    private func updateUI() {
        let context = CoreDataStack.shared.viewContext
        let request: NSFetchRequest<Conversation> = Conversation.fetchRequest()
//        NSSortDescriptor(key: "", ascending: <#T##Bool#>)
        request.sortDescriptors = []
        request.predicate = NSPredicate(format: "any participants.userID = %d", user.id)
        
        fetchedResultsController = NSFetchedResultsController<Conversation>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: "Conversations")
        
        fetchedResultsController?.delegate = self
        try? fetchedResultsController?.performFetch()
        tableView.reloadData()
    }
    
    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conversationCell", for: indexPath)
        
        let conversation = fetchedResultsController?.object(at: indexPath)
        cell.textLabel?.text = conversation?.title
        
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
