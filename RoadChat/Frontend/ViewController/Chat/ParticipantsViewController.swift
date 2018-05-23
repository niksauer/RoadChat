//
//  ParticipantsViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 20.05.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class ParticipantsViewController: UITableViewController, ChangeTitleViewControllerDelegate {

    // MARK: - Typealiases
    typealias ColorPalette = BasicColorPalette
    
    // MARK: - Private Properties
    private let viewFactory: ViewControllerFactory
    private let conversation: Conversation
    private let activeUser: User
    private let colorPalette: ColorPalette
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, conversation: Conversation, activeUser: User, colorPalette: ColorPalette) {
        self.viewFactory = viewFactory
        self.conversation = conversation
        self.activeUser = activeUser
        self.colorPalette = colorPalette
        
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ParticipantCell", bundle: nil), forCellReuseIdentifier: "ParticipantCell")
        tableView.register(UINib(nibName: "TextFieldCell", bundle: nil), forCellReuseIdentifier: "TextFieldCell")
        tableView.register(UINib(nibName: "CenterLabelCell", bundle: nil), forCellReuseIdentifier: "CenterLabelCell")
    }

    // MARK: - ChangeTitleViewController Delegate
    func didChangeTitle() {
        tableView.reloadSections(IndexSet(integer: 0), with: .none)
    }
    
    // MARK: - TableView Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        if conversation.storedParticipants.count > 2 {
            return 3
        } else {
            return 2
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if conversation.storedParticipants.count > 2 {
            switch section {
            case 0:
                return 1
            case 1:
                return conversation.storedParticipants.count
            case 2:
                return 1
            default:
                fatalError()
            }
        } else {
            switch section {
            case 0:
                return conversation.storedParticipants.count
            case 1:
                return 1
            default:
                fatalError()
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        
        if conversation.storedParticipants.count > 2 {
            switch section {
            case 0:
                let cell = UITableViewCell(style: .default, reuseIdentifier: "TitleCell")
                cell.textLabel?.text = conversation.title ?? "No title"
                cell.accessoryType = .disclosureIndicator
                return cell
            case 1:
                let participant = conversation.storedParticipants[row]
                let cell = tableView.dequeueReusableCell(withIdentifier: "ParticipantCell", for: indexPath) as! ParticipantCell
                cell.configure(participant: participant, isAwaitingRequest: participant.storedApprovalStatus == .requested)
                cell.accessoryType = .disclosureIndicator
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CenterLabelCell", for: indexPath) as! CenterLabelCell
                cell.centerTextLabel.text = "Delete"
                cell.centerTextLabel.textColor = colorPalette.destructiveColor
                return cell
            default:
                fatalError()
            }
        } else {
            switch section {
            case 0:
                let participant = conversation.storedParticipants[row]
                let cell = tableView.dequeueReusableCell(withIdentifier: "ParticipantCell", for: indexPath) as! ParticipantCell
                cell.configure(participant: participant, isAwaitingRequest: participant.storedApprovalStatus == .requested)
                cell.accessoryType = .disclosureIndicator
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CenterLabelCell", for: indexPath) as! CenterLabelCell
                cell.centerTextLabel.text = "Delete"
                cell.centerTextLabel.textColor = colorPalette.destructiveColor
                return cell
            default:
                fatalError()
            }
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if conversation.storedParticipants.count > 2 {
            switch section {
            case 0:
                return "Title"
            case 1:
                return "Participants"
            default:
                return nil
            }
        } else {
            switch section {
            case 0:
                return "Participants"
            default:
                return nil
            }
        }
    }
    
    // MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        
        if conversation.storedParticipants.count > 2 {
            switch section {
            case 0:
                let changeTitleViewController = viewFactory.makeChangeTitleViewController(for: conversation)
                changeTitleViewController.delegate = self
                navigationController?.pushViewController(changeTitleViewController, animated: true)
            case 1:
                let participant = conversation.storedParticipants[row]
                let profileViewController = viewFactory.makeProfileViewController(for: participant.user!, activeUser: activeUser, showsPublicProfile: true)
                navigationController?.pushViewController(profileViewController, animated: true)
            case 2:
                conversation.delete { error in
                    guard error == nil else {
                        // handle error
                        return
                    }
                    
                    guard let viewControllers = self.navigationController?.viewControllers else {
                        return
                    }
                    
                    let conversationsViewController = viewControllers[viewControllers.count - 3]
                    self.navigationController?.popToViewController(conversationsViewController, animated: true)
                }
            default:
                break
            }
        } else {
            switch section {
            case 0:
                let participant = conversation.storedParticipants[row]
                let profileViewController = viewFactory.makeProfileViewController(for: participant.user!, activeUser: activeUser, showsPublicProfile: true)
                navigationController?.pushViewController(profileViewController, animated: true)
            case 1:
                conversation.delete { error in
                    guard error == nil else {
                        // handle error
                        return
                    }
                    
                    guard let viewControllers = self.navigationController?.viewControllers else {
                        return
                    }
                    
                    let conversationsViewController = viewControllers[viewControllers.count - 3]
                    self.navigationController?.popToViewController(conversationsViewController, animated: true)
                }
            default:
                break
            }
        }
    }
    
}
