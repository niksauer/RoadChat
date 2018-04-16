//
//  EditProfileViewController.swift
//  RoadChat
//
//  Created by Malcolm Malam on 16.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import RoadChatKit

class EditProfileViewController: UIViewController, UITextViewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var addImageButton: UIButton!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var birthTextView: UITextView!
    
    @IBOutlet weak var maleView: UIView!
    @IBOutlet weak var femaleView: UIView!
    @IBOutlet weak var genderQueerView: UIView!
   
    @IBOutlet weak var streetNameTextField: UITextField!
    @IBOutlet weak var streetNumberTextField: UITextField!
    @IBOutlet weak var postalCodeTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    
    //MARK: - Views
    private let datePickerView = UIDatePicker()
    private var saveBarButtonItem: UIBarButtonItem!
    
    // MARK: - Private Properties
    private let user: User
    private let dateFormatter: DateFormatter
    private let colorPalette: ColorPalette
    private let birthTextViewPlaceholder = "24/11/1996"
    private let bioTextViewPlaceholder = "RoadChats #1 Fan"
    
    private var profileImageView: UIImage
    
    private var username: String?
    private var biography: String?
    
    private var password: String?
    
    private var firstName: String?
    private var lastName: String?
    
    private var birth: Date?
    
    private var sex: String?
    
    private var streetName: String?
    private var streetNumber: Int16
    private var postalCode: int16
    private var city: String?
    private var country: String?
    
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
        // profile image appearance
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
        
        // birth date
        datePickerView.timeZone = TimeZone.current
        datePickerView.datePickerMode = UIDatePickerMode.date
        datePickerView.addTarget(self, action: #selector(didChangeBirthDate(sender:)), for: .valueChanged)
        
        // add photo
        addImageButton.layer.cornerRadius = addImageButton.frame.size.width / 2
        addImageButton.clipsToBounds = true
        addImageButton.backgroundColor = colorPalette.contentBackgroundColor
        
        //Loading userdata in Textfields
        birthTextView.inputView = datePickerView
        guard  birth = user.profile?.birth else {
            //TODO cast to string
            birthTextView.text = birthTextViewPlaceholder
        }
        birthTextView.text = birth
        
        username = user.username
        usernameTextField.text = username
        
        guard biography = user.profile?.biography else {
            birthTextView.text = bioTextViewPlaceholder
        }
        bioTextView.text = biography
        
        //TODO loading Password
        
        guard  firstName = user.profile?.firstName, lastName = user.profile?.lastName else {
            return
        }
        firstNameTextField.text = firstName
        lastNameTextField.text = lastName
        
        sex = user.profile?.sex
        
        switch sex {
        case "male":
            maleView.backgroundColor = UIColor.lightGray
        case "female":
            femaleView.backgroundColor = UIColor.lightGray
        case "genderQueer":
            genderQueerView.backgroundColor = UIColor.lightGray
        default:
            return
        }
        
        guard streetName = user.profile?.streetName, streetNumber = String(user.profile?.streetNumber), postalCode = user.profile?.postalCode, country = user.profile?.country else {
            return
        }
        streetNameTextField.text = streetName
        streetNumberTextField.text = String(streetNumber)
        postalCodeTextField.text = String(postalCode)
        countryTextField.text = country
    }

    // MARK: - Public Methods
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        //TODO Implement Function to check which value has changed
        guard  birth = user.profile?.birth, username = usernameTextField.text, biography = bioTextView.text, firstName = firstNameTextField.text, lastName = lastNameTextField.text, streetName = streetNameTextField.text, streetNumber = Int16(streetNumberTextField.text), postalCode = Int16(postalCodeTextField.text), city = cityTextField.text, country = countryTextField.text else {
            return
        }
        
        let profileRequest = ProfileRequest(firstName, lastName, birth, sex, biography, streetName, streetNumber, postalCode, city, country)
        
        
        user.createOrUpdateProfile(profileRequest) { error in
            guard error == nil else {
                self.displayAlert(title: "Error", message: "Failed to create Profile: \(error)")
                return
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    
    }
    
    @objc func didChangeBirthDate(sender: UIDatePicker) {
        productionTextView.textColor = colorPalette.textColor
        
        // get the date string applied date format
        let selectedDate = dateFormatter.string(from: sender.date)
        birthTextView.text = selectedDate
        
    }
    
    @IBAction func didPressAddImageButton(_ sender: UIButton) {
        // TODO
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == bioTextView, textView.text == bioTextViewPlaceholder {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == bioTextView, textView.text.count == 0 {
            textView.textColor = .lightGray
            textView.text = bioTextViewPlaceholder
        }
    }
    
    // Mark: - Gesture Actions
    @IBAction func didPressView(_ sender: UITapGestureRecognizer) {
        birthTextView.resignFirstResponder()
    }
    
    @IBAction func didPressAddImageButton(_ sender: UIButton) {
    }
    @IBAction func didPressMaleButton(_ sender: UIButton) {
        sex = "male"
        maleView.backgroundColor = UIColor.lightGray
        femaleView.backgroundColor = UIColor.white
        genderQueerView.backgroundColor = UIColor.white
    }
    @IBAction func didPressGenderQueerButton(_ sender: UIButton) {
        sex = "genderQueer"
        maleView.backgroundColor = UIColor.white
        femaleView.backgroundColor = UIColor.white
        genderQueerView.backgroundColor = UIColor.lightGray
    }
    @IBAction func didPressFemaleButton(_ sender: UIButton) {
        sex = "genderQueer"
        maleView.backgroundColor = UIColor.white
        femaleView.backgroundColor = UIColor.lightGray
        genderQueerView.backgroundColor = UIColor.white
    }
    
    
    
}
