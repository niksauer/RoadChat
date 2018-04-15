//
//  CreateCarViewController.swift
//  RoadChat
//
//  Created by Malcolm Malam on 15.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import RoadChatKit

class CreateCarViewController: UIViewController, UIPickerViewDelegate {

    @IBOutlet weak var manufacturerTextField: UITextField!
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var performanceTextField: UITextField!
    @IBOutlet weak var modelTextField: UITextField!
    @IBOutlet weak var productionTextView: UITextView!
    
    private let datePickerView = UIDatePicker()
    private var createBarButtonItem: UIBarButtonItem!
    
    private let user: User
    private let dateFormatter: DateFormatter
    
    private let messageTextViewPlaceholder = "07/2008"
    
    init(user: User, dateFormatter: DateFormatter) {
        self.user = user
        self.dateFormatter = dateFormatter
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = "Add Car"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed(_:)))
        self.createBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButtonPressed(_:)))
        self.createBarButtonItem.isEnabled = false
        self.navigationItem.rightBarButtonItem = createBarButtonItem
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        productionTextView.inputView = datePickerView
        datePickerView.timeZone = NSTimeZone.localTimeZone()
        datePickerView.backgroundColor = UIColor.whiteColor()
        datePickerView.layer.cornerRadius = 5.0
        datePickerView.layer.shadowOpacity = 0.5
        datePickerView.datePickerMode = UIDatePickerMode.date
        
        datePickerView.addTarget(self, action: "onDidChangeDate:", forControlEvents: .ValueChanged)
        
        // add DataPicker to the view
        self.view.addSubview(datePickerView)
        
        productionTextView.text = messageTextViewPlaceholder
        
        // Do any additional setup after loading the view.
    }
    
    internal func onDidChangeDate(sender: UIDatePicker) {
        
        // date format
        
        
        // get the date string applied date format
        let selectedDate: NSString = dateFormatter.stringFromDate(sender.date)
        productionTextView.text = selectedDate as String
    }
    
    // MARK: - Public Methods
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
    
        guard let manufacturer = manufacturerTextField.text, let model = modelTextField.text, let performance = performanceTextField.text, let production = productionTextView.text else {
            
            // handle missingfields error
            return
        }
        let createCarRequest = CarRequest(manufacturer: manufacturer, model: model, production = dateFormatter.date(from: production), performance: performance, color: nil)
    
        user.createCar(createCarRequest) { error in
            guard error == nil else {
                self.displayAlert(title: "Error", message: "Failed to create Car: \(error!)")
                return
            }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didPressAddButton(_ sender: UIButton) {
        //TODO
    }
    
        // MARK: - UITextViewDelegate
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView == productionTextView, textView.text == messageTextViewPlaceholder {
                textView.text = ""
                textView.textColor = .black
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView == productionTextView, textView.text.count == 0 {
                textView.textColor = .lightGray
                textView.text = messageTextViewPlaceholder
            }
        }
        
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
