//
//  PrivacyViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 15.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class PrivacyViewController: GroupedOptionTableViewController {

    // MARK: - Private Properties
    private let privacy: Privacy
    
    // MARK: - Initialization
    init(privacy: Privacy) {
        self.privacy = privacy
        
        let sectionForOptionName = [
            "Location":     0,
            "Email":        1,
            "First Name":   1,
            "Last Name":    1,
            "Birth":        1,
            "Sex":          1,
            "Biography":    1,
            "Street":       1,
            "City":         1,
            "Country":      1
        ]
        
        let rowForOptionName = [
            "Location":     0,
            "Email":        0,
            "First Name":   1,
            "Last Name":    2,
            "Birth":        3,
            "Sex":          4,
            "Biography":    5,
            "Street":       6,
            "City":         7,
            "Country":      8
        ]
        
        let options = privacy.options.map {
            return GroupedOption($0, section: sectionForOptionName[$0.name]!, row: rowForOptionName[$0.name]!)
        }
        
        super.init(options: options)
        
        self.title = "Privacy"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard hasChangedOption else {
            return
        }
        
        privacy.options = options.map { $0.option }
        
        privacy.save { error in
            guard error == nil else {
                // handle error
                return
            }
        }
    }
    
    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "General"
        case 1:
            return "Public Profile"
        default:
            fatalError()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            // explanation of location setting
            let option = options.first(where: { $0.option.name == "Location" })!.option
            
            if option.isEnabled {
                return "Your location is shared with other users. You can be found on a map and contacted via in-app chat."
            } else {
                return "Your location is not shared with other users. You cannot be found on a map and contacted via in-app chat."
            }
        case 1:
            return nil
        default:
            fatalError()
        }
    }

    // MARK: - Switch Cell Delegate
    override func switchCellDidChangeState(_ sender: SwitchCell) {
        super.switchCellDidChangeState(sender)
        
        guard let groupedOption = groupedOption(for: sender) else {
            return
        }
        
        if sender.switchLabel.text == "Location" {
            guard let locationFooter = tableView.footerView(forSection: 0) else {
                return
            }
            
            // update UI
            UIView.setAnimationsEnabled(false)
            tableView.beginUpdates()
            
            let infoText: String
            
            if groupedOption.option.isEnabled {
                 infoText = "Your location is shared with other users. You can be found on a map and contacted via in-app chat."
            } else {
                infoText = "Your location is not shared with other users. You cannot be found on a map and contacted via in-app chat."
            }
            
            locationFooter.textLabel?.text = infoText
            locationFooter.sizeToFit()
            
            tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
    }

}


