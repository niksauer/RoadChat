//
//  CommunityMessagesViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 05.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class CommunityMessagesViewController: UITableViewController, CommunityMessageCellDelegate {
    
    // MARK: - Private Properties
    let messages: [CommunityMessage]?
    let cellDateFormatter: DateFormatter
    
    // MARK: - Initialization
    init(messages: [CommunityMessage]?, cellDateFormatter: DateFormatter) {
        self.messages = messages
        self.cellDateFormatter = cellDateFormatter
        
        super.init(nibName: nil, bundle: nil)
        self.title = "Community"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib.init(nibName: "CommunityMessageCell", bundle: nil), forCellReuseIdentifier: "CommunityMessageCell")
    }
    
    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let message = messages?[indexPath.section] else {
            fatalError()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommunityMessageCell", for: indexPath) as! CommunityMessageCell
        cell.configure(message: message, dateFormatter: cellDateFormatter)
        
        return cell
    }
    
    // MARK: - CommunityMessageCellDelegate Protocol
    func communityMessageCellDidPressUpvote(_ sender: CommunityMessageCell) {
        guard let indexPath = tableView.indexPath(for: sender), let _ = messages?[indexPath.section] else {
            return
        }
    }
    
    func communityMessageCellDidPressDownvote(_ sender: CommunityMessageCell) {
        guard let indexPath = tableView.indexPath(for: sender), let _ = messages?[indexPath.section] else {
            return
        }
    }

}

// MARK: - Table View Data Source
extension CommunityMessagesViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return messages?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(red: 243/255, green: 242/255, blue: 247/255, alpha: 1)
        return headerView
    }
}
