//
//  EditProfileViewController.swift
//  RoadChat
//
//  Created by Malcolm Malam on 16.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import RoadChatKit

class CreateOrEditProfileViewController: UIViewController {

    // MARK: - Typealiases
    typealias ColorPalette = BasicColorPalette & SexColorPalette
    
    // MARK: - Outlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var addImageButton: UIButton!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var biographyTextView: UITextView!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var birthTextField: UITextField!
    @IBOutlet weak var sexTypeSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var streetNameTextField: UITextField!
    @IBOutlet weak var streetNumberTextField: UITextField!
    @IBOutlet weak var postalCodeTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    //MARK: - Views
    private let datePickerView = UIDatePicker()
    private var saveBarButtonItem: UIBarButtonItem!
    
    // MARK: - Private Properties
    private let user: User
    private let dateFormatter: DateFormatter
    private let colorPalette: ColorPalette
    private let bioTextViewPlaceholder = "RoadChats #1 Fan"

    private var sex: SexType? {
        didSet {
            switch sex {
            case .male?:
                sexTypeSegmentedControl.selectedSegmentIndex = 0
            case .female?:
                sexTypeSegmentedControl.selectedSegmentIndex = 1
            case .other?:
                sexTypeSegmentedControl.selectedSegmentIndex = 2
            default:
                return
            }
        }
    }
    
    // MARK: - Initialization
    init(user: User, dateFormatter: DateFormatter, colorPalette: ColorPalette) {
        self.user = user
        self.dateFormatter = dateFormatter
        self.colorPalette = colorPalette
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = "Edit Profile"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed(_:)))
        self.saveBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButtonPressed(_:)))
        self.navigationItem.rightBarButtonItem = saveBarButtonItem
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // keyboard notification
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // dismiss keyboard
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
        
        // profile image appearance
//        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
//        profileImageView.clipsToBounds = true
        
        // birth date picker
        datePickerView.timeZone = TimeZone.current
        datePickerView.datePickerMode = UIDatePickerMode.date
        datePickerView.addTarget(self, action: #selector(didChangeBirthDate(sender:)), for: .valueChanged)
        
        // add photo
        addImageButton.layer.cornerRadius = addImageButton.frame.size.width / 2
        addImageButton.clipsToBounds = true
        addImageButton.backgroundColor = colorPalette.contentBackgroundColor
        addImageButton.tintColor = colorPalette.createColor
        
        // loading existing user data
        usernameTextField.text = user.username
        
        biographyTextView.layer.borderWidth = 1
        biographyTextView.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        biographyTextView.layer.cornerRadius = 5
        biographyTextView.text = user.profile?.biography
        
        firstNameTextField.text = user.profile?.firstName
        lastNameTextField.text = user.profile?.lastName
        birthTextField.inputView = datePickerView
        
        if let birth = user.profile?.birth {
            birthTextField.text = dateFormatter.string(from: birth)
        }
        
        sex = user.profile?.storedSex
        
        streetNameTextField.text = user.profile?.streetName
        
        if let streetNumber = user.profile?.streetNumber {
            streetNumberTextField.text = String(streetNumber)
        }
        
        if let postalCode = user.profile?.postalCode {
            postalCodeTextField.text = String(postalCode)
        }
        
        cityTextField.text = user.profile?.city
        countryTextField.text = user.profile?.country
    }
    
    // MARK: - Public Methods
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func saveButtonPressed(_ sender: UIButton) {
        guard let firstName = firstNameTextField.text, let lastName = lastNameTextField.text, let birthString = birthTextField.text, let birth = dateFormatter.date(from: birthString) else {
            return
        }
        
        var streetNumber: Int?
        
        if let streetNumberString = streetNumberTextField.text {
            streetNumber = Int(streetNumberString)
        }
        
        var postalCode: Int?
        
        if let postalCodeString = postalCodeTextField.text {
            postalCode = Int(postalCodeString)
        }
        
        let profileRequest = ProfileRequest(firstName: firstName, lastName: lastName, birth: birth, sex: sex, biography: biographyTextView.text, streetName: streetNameTextField.text, streetNumber: streetNumber, postalCode: postalCode, city: cityTextField.text, country: countryTextField.text)
        
        user.createOrUpdateProfile(profileRequest) { error in
            guard error == nil else {
                self.displayAlert(title: "Error", message: "Failed to create/update profile: \(error!)") {
                    self.dismiss(animated: true, completion: nil)
                }
                
                return
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func didChangeBirthDate(sender: UIDatePicker) {
        birthTextField.textColor = colorPalette.textColor
        
        // get the date string applied date format
        let selectedDate = dateFormatter.string(from: sender.date)
        birthTextField.text = selectedDate
    }
    
    @IBAction func didChangeSexType(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            sex = .male
        case 1:
            sex = .female
        case 2:
            sex = .other
        default:
            break
        }
    }
    
    @IBAction func didPressAddImageButton(_ sender: UIButton) {
        // TODO
    }

    // MARK: - Keyboard Notifications
    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo! as NSDictionary
        let keyboardFrame = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        bottomConstraint.constant = keyboardHeight
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        bottomConstraint.constant = 0
    }
        
}
