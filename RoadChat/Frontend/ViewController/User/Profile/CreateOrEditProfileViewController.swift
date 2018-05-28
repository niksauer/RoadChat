//
//  EditProfileViewController.swift
//  RoadChat
//
//  Created by Malcolm Malam on 16.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import RoadChatKit

class CreateOrEditProfileViewController: UIViewController, UIImageCropperProtocol, UITextViewDelegate {
    
    // MARK: - Typealiases
    typealias ColorPalette = BasicColorPalette & SexColorPalette
    
    // MARK: - Outlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var birthTextField: UITextField!
    @IBOutlet weak var sexTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var biographyTextView: UITextView!
    
    @IBOutlet weak var streetNameTextField: UITextField!
    @IBOutlet weak var streetNumberTextField: UITextField!
    @IBOutlet weak var postalCodeTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    
    //MARK: - Views
    private var saveBarButtonItem: UIBarButtonItem!
    private let datePickerView = UIDatePicker()
    private let imagePicker = UIImagePickerController()
    private let imageCropper = UIImageCropper(cropRatio: 1)
    
    // MARK: - Private Properties
    private let user: User
    private let dateFormatter: DateFormatter
    private let colorPalette: ColorPalette
    
    private let oldProfile: Profile.Copy?
    private var requestedProfile: Profile.Copy?
    private var shouldUploadProfile = false
    private var shouldUploadImage = false
    
    // MARK: - Initialization
    init(user: User, dateFormatter: DateFormatter, colorPalette: ColorPalette) {
        self.user = user
        self.dateFormatter = dateFormatter
        self.colorPalette = colorPalette
        
        if let profile = user.profile {
            oldProfile = Profile.Copy(firstName: profile.firstName!, lastName: profile.lastName!, birth: profile.birth!, sex: profile.storedSex, streetName: profile.streetName, streetNumber: Int(profile.streetNumber), postalCode: Int(profile.postalCode), city: profile.city, country: profile.country, biography: profile.biography)
        } else {
            oldProfile = nil
        }
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = "Edit Profile"
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
        
        // profile image view height
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
        
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
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
        
        // birth date picker
        datePickerView.timeZone = TimeZone.current
        datePickerView.datePickerMode = UIDatePickerMode.date
        datePickerView.addTarget(self, action: #selector(didChangeBirthDate(sender:)), for: .valueChanged)
        birthTextField.inputView = datePickerView
        
        // add photo button appearance
        addImageButton.layer.cornerRadius = addImageButton.frame.size.width / 2
        addImageButton.clipsToBounds = true
        addImageButton.backgroundColor = colorPalette.contentBackgroundColor
        addImageButton.tintColor = colorPalette.createColor
        
        // textView delegate
        biographyTextView.delegate = self
        
        // textField delegate
        firstNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        lastNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        streetNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        streetNumberTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        postalCodeTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        cityTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        countryTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        // biography text view appearance
        biographyTextView.layer.borderWidth = 0.3
        biographyTextView.layer.borderColor = colorPalette.separatorColor.cgColor
        biographyTextView.layer.cornerRadius = 5
        
        // populate with existing information
        profileImageView.image = user.storedImage
        usernameLabel.text = user.username
        
        guard let profile = user.profile else {
            return
        }
        
        biographyTextView.text = profile.biography
        firstNameTextField.text = profile.firstName
        lastNameTextField.text = profile.lastName
        
        if let birth = profile.birth {
            birthTextField.text = dateFormatter.string(from: birth)
        }
        
        sexTypeSegmentedControl.selectedSegmentIndex = profile.storedSex?.secondRawValue ?? -1
        
        streetNameTextField.text = profile.streetName
        streetNumberTextField.text = profile.streetNumber != -1 ? String(profile.streetNumber) : nil
        postalCodeTextField.text = profile.postalCode != -1 ? String(profile.postalCode) : nil
        cityTextField.text = profile.city
        countryTextField.text = profile.country
    }
    
    // MARK: - Public Methods
    @objc func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func saveButtonPressed(_ sender: UIButton) {
        func uploadImage(_ image: UIImage, for user: User) {
            user.uploadImage(image) { error in
                guard error == nil else {
                    self.displayAlert(title: "Error", message: "Failed to upload image for car: \(error!)") {
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                    return
                }
                
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        guard shouldUploadProfile, let requestedProfile = requestedProfile else {
            if shouldUploadImage {
                uploadImage(profileImageView.image!, for: user)
            }
            
            return
        }

        let profileRequest = ProfileRequest(firstName: requestedProfile.firstName, lastName: requestedProfile.lastName, birth: requestedProfile.birth, sex: requestedProfile.sex, biography: requestedProfile.biography, streetName: requestedProfile.streetName, streetNumber: requestedProfile.streetNumber, postalCode: requestedProfile.postalCode, city: requestedProfile.city, country: requestedProfile.country)
        
        user.createOrUpdateProfile(profileRequest) { error in
            guard error == nil else {
                self.displayAlert(title: "Error", message: "Failed to create/update profile: \(error!)") {
                    self.dismiss(animated: true, completion: nil)
                }
                
                return
            }
            
            guard self.shouldUploadImage else {
                self.dismiss(animated: true, completion: nil)
                return
            }
            
            uploadImage(self.profileImageView.image!, for: self.user)
        }
    }
    
    @IBAction func addImageButtonPressed(_ sender: UIButton) {
        navigationController?.present(imagePicker, animated: true, completion: nil)
    }
    
    func validateSaveButton() {
        if let firstName = firstNameTextField.text, let lastName = lastNameTextField.text, let birthString = birthTextField.text, let birthDate = dateFormatter.date(from: birthString) {
            // retrieve optional fields
            let sex = SexType(secondRawValue: sexTypeSegmentedControl.selectedSegmentIndex)
            
            let streetName: String?
            if let streetNameString = streetNameTextField.text, !streetNameString.isEmpty {
                streetName = streetNameString
            } else {
                streetName = nil
            }
            
            let streetNumber = Int(streetNumberTextField.text!) ?? -1
            let postalCode = Int(postalCodeTextField.text!) ?? -1
            
            let city: String?
            if let cityString = cityTextField.text, !cityString.isEmpty {
                city = cityString
            } else {
                city = nil
            }
            
            let country: String?
            if let countryString = countryTextField.text, !countryString.isEmpty {
                country = countryString
            } else {
                country = nil
            }
            
            let biography: String?
            if let biographyString = biographyTextView.text, !biographyString.isEmpty {
                biography = biographyString
            } else {
                biography = nil
            }
            
            // prepare new car
            requestedProfile = Profile.Copy(firstName: firstName, lastName: lastName, birth: birthDate, sex: sex, streetName: streetName, streetNumber: streetNumber, postalCode: postalCode, city: city, country: country, biography: biography)
            
            if let oldProfile = oldProfile {
                // check whether existing profile has been modified
                shouldUploadProfile = requestedProfile != oldProfile
            } else {
                shouldUploadProfile = true
            }
        } else {
            // handle missing required fields error
            shouldUploadProfile = false
        }
        
        saveBarButtonItem.isEnabled = shouldUploadProfile || shouldUploadImage
    }
    
    // Mark: - DatePicker Delegate
    @objc func didChangeBirthDate(sender: UIDatePicker) {
        birthTextField.textColor = colorPalette.darkTextColor
        
        // get the date string applied date format
        let selectedDate = dateFormatter.string(from: sender.date)
        birthTextField.text = selectedDate
        
        validateSaveButton()
    }
    
    // Mark: - SegmentedControl Delegate
    @IBAction func didChangeSexType(_ sender: UISegmentedControl) {
        validateSaveButton()
    }
    
    // Mark: - TextView Delegate
    func textViewDidChange(_ textView: UITextView) {
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
    
    // Mark: - UIImageCropper Delegate
    func didCropImage(originalImage: UIImage?, croppedImage: UIImage?) {
        if let image = croppedImage {
            shouldUploadImage = true
            profileImageView.image = image
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
