//
//  TrafficBoardViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 01.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import RoadChatKit
import CoreData

class TrafficBoardViewController: FetchedResultsTableViewController {
    
    // MARK: - Private Properties
    private let viewFactory: ViewControllerFactory
    private let trafficBoard: TrafficBoard
    private let searchContext: NSManagedObjectContext
    
    private var fetchedResultsController: NSFetchedResultsController<TrafficMessage>?
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, trafficBoard: TrafficBoard, searchContext: NSManagedObjectContext) {
        self.viewFactory = viewFactory
        self.trafficBoard = trafficBoard
        self.searchContext = searchContext
        
        super.init(nibName: nil, bundle: nil)
        self.title = "TrafficBoard"
        self.tabBarItem = UITabBarItem(title: "Traffic", image: #imageLiteral(resourceName: "car"), tag: 1)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "create_new"), style: .plain, target: nil, action: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib.init(nibName: "TrafficMessageCell", bundle: nil), forCellReuseIdentifier: "TrafficMessageCell")
        trafficBoard.getMessages(completion: nil)
        updateUI()

    }
    
    // MARK: - Private Methods
    private func updateUI() {
        let request: NSFetchRequest<TrafficMessage> = TrafficMessage.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "time", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController<TrafficMessage>(fetchRequest: request, managedObjectContext: searchContext, sectionNameKeyPath: nil, cacheName: "TrafficBoard")
        fetchedResultsController?.delegate = self
        try? fetchedResultsController?.performFetch()
        
        tableView.reloadData()
    }
    
    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let trafficMessage = fetchedResultsController!.object(at: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrafficMessageCell", for: indexPath) as! TrafficMessageCell
        cell.configure(trafficMessage: trafficMessage)
        
        return cell
    }
    
}

// MARK: - Table View Data Source
extension TrafficBoardViewController {
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

