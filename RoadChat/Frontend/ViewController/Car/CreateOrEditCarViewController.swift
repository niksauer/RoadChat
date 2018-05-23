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

class CreateOrEditCarViewController: UIViewController, UIPickerViewDelegate, UITextFieldDelegate {

    // MARK: - Typealiases
    typealias ColorPalette = BasicColorPalette & CarColorPalette
    
    // MARK: - Outlets
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var addImageButton: UIButton!
    
    @IBOutlet weak var manufacturerTextField: UITextField!
    @IBOutlet weak var modelTextField: UITextField!
    
    @IBOutlet weak var performanceTextField: UITextField!
    @IBOutlet weak var productionTextField: UITextField!
    
    @IBOutlet weak var colorPickerContainer: UIView!
    @IBOutlet weak var colorPickerField: UIView!

    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    // MARK: - Views
    private let monthYearDatePickerView = MonthYearPickerView()
    private var saveBarButtonItem: UIBarButtonItem!
    private var adjustBrightnessLabel = EdgeInsetLabel()
    private let colorPickerView = ColorCircle()

    // MARK: - Private Properties
    private let user: User
    private let car: Car?
    private let productionDateFormatter: DateFormatter
    private let colorPalette: ColorPalette
    
    // MARK: - Initialization
    init(user: User, car: Car?, productionDateFormatter: DateFormatter, colorPalette: ColorPalette) {
        self.user = user
        self.car = car
        self.productionDateFormatter = productionDateFormatter
        self.colorPalette = colorPalette
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = "New Car"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed(_:)))
        self.saveBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButtonPressed(_:)))
        self.saveBarButtonItem.isEnabled = false
        self.navigationItem.rightBarButtonItem = saveBarButtonItem
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // keyboard notification
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // dismiss keyboard
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
        
        // additional view setup
        deleteButton.tintColor = colorPalette.destructiveColor
        
        // production date
        monthYearDatePickerView.years = {
            let maxYearsAgo = 70
            let currentYear = Calendar(identifier: Calendar.Identifier.gregorian).component(.year, from: Date())
            
            var years = [Int]()
            var year = currentYear
            
            for _ in 1...maxYearsAgo {
                years.append(year)
                year -= 1
            }
            
            return years.reversed()
        }()
    
//        let currentYear = Calendar(identifier: Calendar.Identifier.gregorian).component(.year, from: Date())
//        monthYearDatePickerView.selectRow(monthYearDatePickerView.years.index(of: currentYear)!, inComponent: 1, animated: true)
        
        monthYearDatePickerView.onDateSelected = didChangeProductionDate(month:year:)
        productionTextField.inputView = monthYearDatePickerView
        
        // add photo
        addImageButton.layer.cornerRadius = addImageButton.frame.size.width / 2
        addImageButton.clipsToBounds = true
        addImageButton.tintColor = colorPalette.createColor
        addImageButton.backgroundColor = colorPalette.contentBackgroundColor
        
        // color picker
        colorPickerField.backgroundColor = colorPalette.defaultCarColor
        colorPickerField.layer.cornerRadius = 10
        
        colorPickerView.setColor(colorPalette.defaultCarColor, animated: false, sendEvent: false)
        colorPickerView.frame = CGRect(x: view.frame.width / 2, y: view.frame.height / 2, width: 200, height: 200)
        colorPickerView.addTarget(self, action: #selector(didChangeColor), for: .valueChanged)
        colorPickerView.translatesAutoresizingMaskIntoConstraints = false
        
        adjustBrightnessLabel.translatesAutoresizingMaskIntoConstraints = false
        adjustBrightnessLabel.textInsets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
        adjustBrightnessLabel.layer.cornerRadius = 4
        adjustBrightnessLabel.clipsToBounds = true
        adjustBrightnessLabel.backgroundColor = colorPalette.contentBackgroundColor
        adjustBrightnessLabel.text = "Pinch to adjust Brightness"
        adjustBrightnessLabel.textColor = colorPalette.darkTextColor
        
        colorPickerContainer.backgroundColor = colorPalette.overlayBackgroundColor
        colorPickerContainer.addSubview(colorPickerView)
        colorPickerContainer.addSubview(adjustBrightnessLabel)
    
        NSLayoutConstraint.activate([
            colorPickerView.centerYAnchor.constraint(equalTo: colorPickerContainer.centerYAnchor),
            colorPickerView.centerXAnchor.constraint(equalTo: colorPickerContainer.centerXAnchor),
            adjustBrightnessLabel.centerXAnchor.constraint(equalTo: colorPickerContainer.centerXAnchor),
            adjustBrightnessLabel.centerYAnchor.constraint(equalTo: colorPickerView.bottomAnchor, constant: 35)
        ])
        
        // textfield delegate
        manufacturerTextField.delegate = self
        modelTextField.delegate = self
        performanceTextField.delegate = self
        
        
        // populate with existing information
        guard let car = car else {
            return
        }
        
        self.title = "Edit Car"
        
        manufacturerTextField.text = car.manufacturer
        modelTextField.text = car.model
        performanceTextField.text = car.performance != 1 ? String(car.performance) : nil
        
        if let production = car.production {
            productionTextField.text = productionDateFormatter.string(from: production)
        }
        
        colorPickerField.backgroundColor = car.storedColor
    }
    
    // MARK: - Public Methods
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        guard let manufacturer = manufacturerTextField.text, let model = modelTextField.text, let performanceString = performanceTextField.text, let performance = Int(performanceString), let productionString = productionTextField.text, let production = productionDateFormatter.date(from: productionString) else {
            // handle missing fields error
            return
        }
    
        let hexColorString = colorPickerField.backgroundColor!.toHexString()
        let createCarRequest = CarRequest(manufacturer: manufacturer, model: model, production: production, performance: performance, color: hexColorString)
    
        if let car = car {
            car.manufacturer = manufacturer
            car.model = model
            car.performance = Int16(performance)
            car.production = production
            car.color = hexColorString
            
            car.save { error in
                guard error == nil else {
                    self.displayAlert(title: "Error", message: "Failed to update Car: \(error!)") {
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                    return
                }
                
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            user.createCar(createCarRequest) { error in
                guard error == nil else {
                    self.displayAlert(title: "Error", message: "Failed to create Car: \(error!)") {
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                    return
                }
                
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    func didChangeProductionDate(month: Int, year: Int) {
        self.productionTextField.textColor = self.colorPalette.darkTextColor
        self.productionTextField.text = String(format: "%02d/%d", month, year)
        validateSaveButton()
    }
    
    @IBAction func didPressAddImageButton(_ sender: UIButton) {
        // TODO
    }
    
    func validateSaveButton() {
        guard let manufacturer = manufacturerTextField.text, !manufacturer.isEmpty, let model = modelTextField.text, !model.isEmpty, let performanceString = performanceTextField.text, let _ = Int(performanceString) else {
            saveBarButtonItem.isEnabled = false
            return
        }
        
        saveBarButtonItem.isEnabled = true
    }

    @IBAction func didPressDeleteButton(_ sender: UIButton) {
        car?.delete { error in
            guard error == nil else {
                self.displayAlert(title: "Error", message: "Failed to delete Car: \(error!)") {
                    self.dismiss(animated: true, completion: nil)
                }
                
                return
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // Mark: - TextField Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        validateSaveButton()
        return true
    }
    
    // Mark: - Tap Gesture Recognizer
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func didPressColorField(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
        colorPickerContainer.isHidden = false
    }
    
    @IBAction func didPressOutsideColorPicker(_ sender: UITapGestureRecognizer) {
        colorPickerContainer.isHidden = true
    }
    
    // Mark: - Private Methods
    @objc private func didChangeColor() {
        colorPickerField.backgroundColor = colorPickerView.color
        validateSaveButton()
    }
    
    // MARK: - Keyboard Notifications
    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo! as NSDictionary
        let keyboardFrame = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        bottomConstraint.constant = keyboardHeight - view.safeAreaInsets.bottom
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        bottomConstraint.constant = 0
    }
    
    
}
