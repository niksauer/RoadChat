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

class CreateOrEditCarViewController: UIViewController, UIImageCropperProtocol {

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

    @IBOutlet weak var deleteContainer: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var carImageViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Views
    private var saveBarButtonItem: UIBarButtonItem!
    private let monthYearDatePickerView = MonthYearPickerView()
    private let colorPickerView = ColorCircle()
    private let adjustBrightnessLabel = EdgeInsetLabel()
    private let imagePicker = UIImagePickerController()
    private let imageCropper = UIImageCropper(cropRatio: 4/3)

    // MARK: - Private Properties
    private let owner: User
    private let car: Car?
    private let activeUser: User
    private let productionDateFormatter: DateFormatter
    private let colorPalette: ColorPalette
    
    private let oldCar: Car.Copy?
    private var requestedCar: Car.Copy?
    private var shouldUploadCar = false
    private var shouldUploadImage = false

    // MARK: - Initialization
    init(owner: User, car: Car?, activeUser: User, productionDateFormatter: DateFormatter, colorPalette: ColorPalette) {
        self.owner = owner
        self.car = car
        self.activeUser = activeUser
        self.productionDateFormatter = productionDateFormatter
        self.colorPalette = colorPalette
    
        if activeUser.id == owner.id {
            if let car = car {
                // edit car
                oldCar = Car.Copy(manufacturer: car.manufacturer!, model: car.model!, production: car.production!, performance: Int(car.performance), color: car.color)
                super.init(nibName: nil, bundle: nil)
                self.title = "Edit Car"
            } else {
                // create car
                oldCar = nil
                super.init(nibName: nil, bundle: nil)
                self.title = "New Car"
            }
            
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed(_:)))
            self.saveBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButtonPressed(_:)))
            self.saveBarButtonItem.isEnabled = false
            self.navigationItem.rightBarButtonItem = saveBarButtonItem
        } else {
            oldCar = nil
            super.init(nibName: nil, bundle: nil)
            self.title = "New Car"
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(cancelButtonPressed(_:)))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // car image view height
        carImageViewHeightConstraint.constant = (view.frame.width/4)*3
        
        // color picker container
        colorPickerField.backgroundColor = colorPalette.defaultCarColor
        colorPickerField.layer.cornerRadius = 10
        
        // populate with existing information
        if let car = car {
            carImageView.image = car.storedImage
            manufacturerTextField.text = car.manufacturer
            modelTextField.text = car.model
            performanceTextField.text = car.performance != -1 ? String(car.performance) : nil
            
            if let production = car.production {
                productionTextField.text = productionDateFormatter.string(from: production)
            }
            
            colorPickerField.backgroundColor = car.storedColor
        }
    
        guard activeUser.id == owner.id else {
            // external visitor
            deleteContainer.isHidden = true
            addImageButton.isHidden = true
            self.title = nil
            
            manufacturerTextField.isEnabled = false
            modelTextField.isEnabled = false
            performanceTextField.isEnabled = false
            productionTextField.isEnabled = false
            return
        }

        // image picker & cropper
        imageCropper.picker = imagePicker
        imageCropper.delegate = self
        imageCropper.autoClosePicker = true
        imageCropper.cancelButtonText = "Cancel"
        imageCropper.cropButtonText = "Select"
        
        // keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // dismiss keyboard
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard (_:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
        
        // color picker tapping
        let colorPickerViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapColorField(_:)))
        colorPickerField.addGestureRecognizer(colorPickerViewTapGestureRecognizer)
        
        let outsideColorPickerViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOutsideColorPicker(_:)))
        colorPickerContainer.addGestureRecognizer(outsideColorPickerViewTapGestureRecognizer)
        
        // additional view setup
        deleteButton.tintColor = colorPalette.destructiveColor
        
        // production date picker
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
        
        // add photo button appearance
        addImageButton.layer.cornerRadius = addImageButton.frame.size.width / 2
        addImageButton.clipsToBounds = true
        addImageButton.tintColor = colorPalette.createColor
        addImageButton.backgroundColor = colorPalette.contentBackgroundColor
        
        // color picker view
        colorPickerView.setColor(colorPalette.defaultCarColor, animated: false, sendEvent: false)
        colorPickerView.frame = CGRect(x: view.frame.width / 2, y: view.frame.height / 2, width: 200, height: 200)
        colorPickerView.addTarget(self, action: #selector(didChangeColor), for: .valueChanged)
        colorPickerView.translatesAutoresizingMaskIntoConstraints = false
        
        adjustBrightnessLabel.translatesAutoresizingMaskIntoConstraints = false
        adjustBrightnessLabel.textInsets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
        adjustBrightnessLabel.layer.cornerRadius = 4
        adjustBrightnessLabel.clipsToBounds = true
        adjustBrightnessLabel.backgroundColor = colorPalette.contentBackgroundColor
        adjustBrightnessLabel.text = "Pinch to adjust brightness"
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
        manufacturerTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        modelTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        performanceTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    // MARK: - Public Methods
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        func uploadImage(_ image: UIImage, for car: Car) {
            car.uploadImage(image) { error in
                guard error == nil else {
                    self.displayAlert(title: "Error", message: "Failed to upload image for car: \(error!)") {
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                    return
                }
                
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        guard shouldUploadCar, let requestedCar = requestedCar else {
            if let car = car, shouldUploadImage {
                uploadImage(self.carImageView.image!, for: car)
            }
            
            return
        }
        
        if let car = car {
            car.manufacturer = requestedCar.manufacturer
            car.model = requestedCar.model
            car.production = requestedCar.production
            car.performance = Int16(requestedCar.performance ?? -1)
            car.color = requestedCar.color
            
            car.save { error in
                guard error == nil else {
                    self.displayAlert(title: "Error", message: "Failed to update car: \(error!)") {
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                    return
                }
                
                guard self.shouldUploadImage else {
                    self.dismiss(animated: true, completion: nil)
                    return
                }
                
                uploadImage(self.carImageView.image!, for: car)
            }
        } else {
            let carRequest = CarRequest(manufacturer: requestedCar.manufacturer, model: requestedCar.model, production: requestedCar.production, performance: requestedCar.performance, color: requestedCar.color)
            
            activeUser.createCar(carRequest) { car, error in
                guard let car = car else {
                    self.displayAlert(title: "Error", message: "Failed to create car: \(error!)") {
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                    return
                }
                
                guard self.shouldUploadImage else {
                    self.dismiss(animated: true, completion: nil)
                    return
                }
                
                uploadImage(self.carImageView.image!, for: car)
            }
        }
    }

    @IBAction func addImageButtonPressed(_ sender: UIButton) {
        navigationController?.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        car?.delete { error in
            guard error == nil else {
                self.displayAlert(title: "Error", message: "Failed to delete car: \(error!)") {
                    self.dismiss(animated: true, completion: nil)
                }
                
                return
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func validateSaveButton() {
        if let manufacturer = manufacturerTextField.text, !manufacturer.isEmpty, let model = modelTextField.text, !model.isEmpty, let productionString = productionTextField.text, let production = productionDateFormatter.date(from: productionString), let performanceString = performanceTextField.text, let performance = Int(performanceString), let hexColorString = colorPickerField.backgroundColor?.toHexString() {
            
            // prepare new car
            requestedCar = Car.Copy(manufacturer: manufacturer, model: model, production: production, performance: performance, color: hexColorString)
            
            if let oldCar = oldCar {
                // check whether existing car has been modified
                shouldUploadCar = requestedCar != oldCar
            } else {
                shouldUploadCar = true
            }
        } else {
            // handle missing required fields error
            shouldUploadCar = false
        }
        
        if oldCar == nil {
            shouldUploadImage = false
        }
        
        saveBarButtonItem.isEnabled = shouldUploadCar || shouldUploadImage
    }
    
    // Mark: - ColorPickerView Delegate
    @objc func didChangeColor() {
        colorPickerField.backgroundColor = colorPickerView.color
        validateSaveButton()
    }
    
    // Mark: - MonthYearDatePickerView Delegate
    func didChangeProductionDate(month: Int, year: Int) {
        self.productionTextField.textColor = self.colorPalette.darkTextColor
        self.productionTextField.text = String(format: "%02d/%d", month, year)
        validateSaveButton()
    }
    
    // Mark: - TextField Delegate
    @objc func textFieldDidChange(_ textField: UITextField) {
        validateSaveButton()
    }
    
    // Mark: - Tap Gesture Recognizer
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func didTapColorField(_ sender: UITapGestureRecognizer) {
        dismissKeyboard(sender)
        colorPickerContainer.isHidden = false
    }
    
    @IBAction func didTapOutsideColorPicker(_ sender: UITapGestureRecognizer) {
        colorPickerContainer.isHidden = true
    }
    
    // Mark: - ImageCropper Delegate
    func didCropImage(originalImage: UIImage?, croppedImage: UIImage?) {
        if let image = croppedImage {
            shouldUploadImage = true
            carImageView.image = image
        } else {
            shouldUploadImage = false
        }
        
        validateSaveButton()
    }
    
    // MARK: - Keyboard Notifications
    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo! as NSDictionary
        let keyboardFrame = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        if #available(iOS 11.0, *) {
            viewBottomConstraint.constant = keyboardHeight - view.safeAreaInsets.bottom
        } else {
            viewBottomConstraint.constant = keyboardHeight
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        viewBottomConstraint.constant = 0
    }
    
}
