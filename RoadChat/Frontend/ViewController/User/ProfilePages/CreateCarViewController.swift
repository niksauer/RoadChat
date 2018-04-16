//
//  CreateCarViewController.swift
//  RoadChat
//
//  Created by Malcolm Malam on 15.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import RoadChatKit
import ColorCircle

class CreateCarViewController: UIViewController, UIPickerViewDelegate {

    // MARK: - Typealiases
    typealias ColorPalette = BasicColorPalette
    
    // MARK: - Outlets
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var addImageButton: UIButton!
    
    @IBOutlet weak var manufacturerTextField: UITextField!
    @IBOutlet weak var modelTextField: UITextField!
    
    @IBOutlet weak var performanceTextField: UITextField!
    
    @IBOutlet weak var productionTextView: UITextView!
    @IBOutlet weak var colorPickerView: UIView!
    
    // MARK: - Private Properties
    private let datePickerView = UIDatePicker()
    private var createBarButtonItem: UIBarButtonItem!
    
    
    private let user: User
    private let dateFormatter: DateFormatter
    private let colorPalette: ColorPalette
    private let colorCircle: ColorCircle
    private var activeColorCircle: Bool = false
    private let defaultColor: UIColor = .groupTableViewBackground
    
    private let messageTextViewPlaceholder = "07/2008"
    
    // MARK: - Initialization
    init(user: User, dateFormatter: DateFormatter, colorPalette: ColorPalette) {
        self.user = user
        self.dateFormatter = dateFormatter
        self.colorPalette = colorPalette
        
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
    
    // MARK: - Customization
    override func viewDidLoad() {
        datePickerView.timeZone = TimeZone.current
        datePickerView.datePickerMode = UIDatePickerMode.date
        datePickerView.addTarget(self, action: #selector(didChangeProductionDate(sender:)), for: .valueChanged)
        
        productionTextView.inputView = datePickerView
        productionTextView.text = messageTextViewPlaceholder
        
        addImageButton.layer.cornerRadius = addImageButton.frame.size.width / 2
        addImageButton.clipsToBounds = true
        addImageButton.backgroundColor = colorPalette.contentBackgroundClor
        
        colorCircle = ColorCircle()
        colorCircle.frame = CGRect(x: view.frame.width / 2, y: view.frame.height / 2, width: 200, height: 200)
        colorCircle.addTarget(self, action: #selector(changeColor), for: .valueChanged)
        colorPickerView.layer.cornerRadius = 10
//        addImageButton.backgroundColor?.withAlphaComponent(0.5)
        
//        addImageButton.layer.shadowColor = UIColor.black.cgColor
//        addImageButton.layer.shadowOffset = CGSize.zero
//        addImageButton.layer.shadowOpacity = 1
//        addImageButton.layer.shadowRadius = 10
//        addImageButton.layer.shouldRasterize = true
    }
    
    // MARK: - Public Methods
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        let color
        
        if colorPickerView.backgroundColor = defaultColor {
            color = nil
        } else {
            color = colorPickerView.backgroundColor
        }
        
        guard let manufacturer = manufacturerTextField.text, let model = modelTextField.text, let performanceString = performanceTextField.text, let performance = Int(performanceString), let productionString = productionTextView.text, let production = dateFormatter.date(from: productionString) else {
            
            // handle missingfields error
            return
        }
    
        let createCarRequest = CarRequest(manufacturer: manufacturer, model: model, production: production, performance: performance, color: color)
    
        user.createCar(createCarRequest) { error in
            guard error == nil else {
                self.displayAlert(title: "Error", message: "Failed to create Car: \(error!)")
                return
            }
        
            self.dismiss(animated: true, completion: nil)
        }
    }

    @objc func didChangeProductionDate(sender: UIDatePicker) {
        productionTextView.textColor = colorPalette.textColor
        // get the date string applied date format
        let selectedDate = dateFormatter.string(from: sender.date)
        productionTextView.text = selectedDate
        
        if (manufacturerTextField.text != "" && modelTextField.text != "" && performanceTextField.text != "") {
            createBarButtonItem.isEnabled = true
        }
    }
    
    @IBAction func didPressAddImageButton(_ sender: UIButton) {
        // TODO
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
    
    // Mark: - Gesture Actions
    @IBAction func didPressUIView(_ sender: UITapGestureRecognizer) {
        datePickerView.isHidden = true
        if activeColorCircle {
        colorCircle.removeFromSuperview()
        activeColorCircle = false
        }
    }
    @IBAction func didPressColorView(_ sender: UITapGestureRecognizer) {
        activeColorCircle = true
        view.addSubview(colorCircle)
    }
    
    // Mark: - Private Methods
    private func changeColor(){
        colorPickerView.backgroundColor = colorCircle.color
    }
    
}
