//
//  UIViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 11.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func displayAlert(title: String, message: String, completion: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { alertAction in
            completion?()
        }))
        self.present(alertController, animated: true, completion: nil)
    }

    func displayConfirmationDialog(title: String, message: String, type: UIAlertActionStyle = .default, onCancel: ((UIAlertAction) -> Void)?, onConfirm: ((UIAlertAction) -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Confirm", style: type, handler: onConfirm))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: onCancel))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func displayInputDialog(title: String, message: String, placeholder: String, onCancel: ((UIAlertAction) -> Void)?, onConfirm: @escaping ((String?) -> Void)) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = placeholder
        }
        
        alertController.addAction(UIAlertAction(title: "Confirm", style: .default) { (alertAction) in
            let textField = alertController.textFields![0] as UITextField
            onConfirm(textField.text)
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: onCancel))
        self.present(alertController, animated: true, completion: nil)
    }
}
