//
//  CommunityBoardViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 01.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import CoreData

class CommunityBoardViewController: FetchedResultsTableViewController   {
 
    // MARK: - Private Properties
    private let viewFactory: ViewControllerFactory
    private let communityBoard: CommunityBoard
    private let searchContext: NSManagedObjectContext
    
    private var fetchedResultsController: NSFetchedResultsController<CommunityMessage>?
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, communityBoard: CommunityBoard, searchContext: NSManagedObjectContext) {
        self.viewFactory = viewFactory
        self.communityBoard = communityBoard
        self.searchContext = searchContext
        
        super.init(nibName: nil, bundle: nil)
        self.title = "CommunityBoard"
        self.tabBarItem = UITabBarItem(title: "Community", image: #imageLiteral(resourceName: "collaboration"), tag: 0)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "create_new"), style: .plain, target: self, action: #selector(createButtonPressed(_:)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib.init(nibName: "CommunityMessageCell", bundle: nil), forCellReuseIdentifier: "CommunityMessageCell")
        updateUI()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        let communityMessage = fetchedResultsController!.object(at: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommunityMessageCell", for: indexPath) as! CommunityMessageCell
        //cell.configure(communityMessage: communityMessage)
        
        return cell
    }
}
    
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
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    

