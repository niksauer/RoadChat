//
//  ChangeTitleViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 18.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import RoadChatKit

protocol ChangeTitleViewControllerDelegate {
    func didChangeTitle(to title: String)
}

class ChangeTitleViewController: UITableViewController {

    // MARK: - Views
    private var doneBarButton: UIBarButtonItem!
    
    // MARK: - Public Properties
    var delegate: ChangeTitleViewControllerDelegate?
    
    // MARK: - Private Properties
    private let conversation: Conversation
    
    private var newTitle: String? {
        didSet {
            validateDoneButton()
        }
    }
    
    // MARK: - Initialization
    init(conversation: Conversation) {
        self.conversation = conversation
        
        super.init(style: .grouped)
        
        self.title = "Title"
        doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didPressDoneButton(_:)))
        self.navigationItem.rightBarButtonItem = doneBarButton
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "TextFieldCell", bundle: nil), forCellReuseIdentifier: "TextFieldCell")
        tableView.allowsSelection = false
        doneBarButton.isEnabled = false
    }
    
    // MARK: - Public Methods
    @objc func didPressDoneButton(_ sender: UIBarButtonItem) {
        guard let title = newTitle else {
            return
        }
        
        conversation.title = title
        
        conversation.save { error in
            guard error == nil else {
                // handle error
                return
            }
            
            self.delegate?.didChangeTitle(to: title)
            self.navigationController?.popViewController(animated: true)
        }
    }

    func didChangeTitle(_ sender: UITextField) {
        newTitle = sender.text
    }
    
    func validateDoneButton() {
        guard let title = newTitle, !title.isEmpty else {
            doneBarButton.isEnabled = false
            return
        }
        
        doneBarButton.isEnabled = (title != conversation.title)
    }
    
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            fatalError()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        
        switch section {
        case 0:
            switch row {
            case 0:
                // new title
                let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldCell
                cell.textField.placeholder = "Enter title"
                cell.textField.text = conversation.title
                cell.configure(text: "Title", onChange: didChangeTitle(_:))
                return cell
            default:
                fatalError()
            }
        default:
            fatalError()
        }
    }
    
}
