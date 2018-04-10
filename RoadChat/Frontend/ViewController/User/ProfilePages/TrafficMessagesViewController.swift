//
//  TrafficMessagesViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 05.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class TrafficMessagesViewController: UITableViewController {

    // MARK: - Outlets
    
    // MARK: - Private Properties
    let messages: [TrafficMessage]?
    let cellDateFormatter: DateFormatter
    
    // MARK: - Initialization
    init(messages: [TrafficMessage]?, cellDateFormatter: DateFormatter) {
        self.messages = messages
        self.cellDateFormatter = cellDateFormatter
        
        super.init(nibName: nil, bundle: nil)
        self.title = "Traffic"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let message = messages?[indexPath.row] else {
            fatalError()
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "TrafficMessageCell", for: indexPath) as! TrafficMessageCell
        cell.configure(message: message, dateFormatter: cellDateFormatter)

        return cell
    }

}

// MARK: - Table View Data Source
extension TrafficMessagesViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages?.count ?? 0
    }
}