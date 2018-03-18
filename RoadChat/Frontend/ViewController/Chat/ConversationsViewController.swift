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
    
    var user: User!
    
    private var fetchedResultsController: NSFetchedResultsController<Conversation>?
    
    override func viewDidLoad() {
        updateUI()
        
//        User.findOrRetrieveById(CredentialManager.shared.getUserID()!) { user, error in
//            guard let user = user else {
//                return
//            }
//
//            user.getConversations { error in
//                guard error == nil else {
//                    // handle retrieval error
//                    return
//                }
//            }
//        }
    }
    
    private func updateUI() {
        guard let userID = CredentialManager.shared.getUserID() else {
            // handle missing userID error of logged in user
            return
        }
        
        let context = CoreDataStack.shared.viewContext
        let request: NSFetchRequest<Conversation> = Conversation.fetchRequest()
//        NSSortDescriptor(key: "", ascending: <#T##Bool#>)
        request.sortDescriptors = []
        request.predicate = NSPredicate(format: "any participants.userID = %d", userID)
        
        fetchedResultsController = NSFetchedResultsController<Conversation>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: "Conversations")
        
        fetchedResultsController?.delegate = self
        try? fetchedResultsController?.performFetch()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conversationCell", for: indexPath)
        
        let conversation = fetchedResultsController?.object(at: indexPath)
        cell.textLabel?.text = conversation?.title
        
        return cell
    }
}

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
