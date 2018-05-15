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

    // MARK: - Views
    private let monthYearDatePickerView = MonthYearPickerView()
    private var saveBarButtonItem: UIBarButtonItem!
    private var adjustBrightnessLabel: UILabel!
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
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
        
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
        
//        addImageButton.backgroundColor?.withAlphaComponent(0.5)
//        addImageButton.layer.shadowColor = UIColor.black.cgColor
//        addImageButton.layer.shadowOffset = CGSize.zero
//        addImageButton.layer.shadowOpacity = 1
//        addImageButton.layer.shadowRadius = 10
//        addImageButton.layer.shouldRasterize = true
        
        // color picker
        colorPickerField.backgroundColor = colorPalette.defaultCarColor
        colorPickerField.layer.cornerRadius = 10
        
        colorPickerView.setColor(colorPalette.defaultCarColor, animated: false, sendEvent: false)
        colorPickerView.frame = CGRect(x: view.frame.width / 2, y: view.frame.height / 2, width: 200, height: 200)
        colorPickerView.addTarget(self, action: #selector(didChangeColor), for: .valueChanged)
        colorPickerView.translatesAutoresizingMaskIntoConstraints = false
        
        adjustBrightnessLabel.text = "Pinch to adjust Brightness"
        adjustBrightnessLabel.textColor = .white
        
        colorPickerContainer.backgroundColor = colorPalette.controlBackgroundColor
        colorPickerContainer.addSubview(colorPickerView)
        colorPickerContainer.addSubview(adjustBrightnessLabel)
    
        NSLayoutConstraint.activate([
            colorPickerView.centerYAnchor.constraint(equalTo: colorPickerContainer.centerYAnchor),
            colorPickerView.centerXAnchor.constraint(equalTo: colorPickerContainer.centerXAnchor),
            adjustBrightnessLabel.centerXAnchor.constraint(equalTo: colorPickerContainer.centerXAnchor)
            adjustBrightnessLabel.centerYAnchor.constraint(equalTo: colorPickerContainer.bottomAnchor, constant: 20)
        ])
        
        // textfield delegate
        manufacturerTextField.delegate = self
        modelTextField.delegate = self
        performanceTextField.delegate = self
        
        
        // populate with existing information
        guard let car = car else {
            return
        }
        
        manufacturerTextField.text = car.manufacturer
        modelTextField.text = car.model
        performanceTextField.text = String(car.performance)
        
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

    func didChangeProductionDate(month: Int, year: Int) {
        self.productionTextField.textColor = self.colorPalette.textColor
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
    
}
