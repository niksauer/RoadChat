//
//  EditProfileViewController.swift
//  RoadChat
//
//  Created by Malcolm Malam on 16.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import RoadChatKit

class CreateOrEditProfileViewController: UIViewController, UITextViewDelegate {

    // MARK: - Typealiases
    typealias ColorPalette = BasicColorPalette & SexColorPalette
    
    // MARK: - Outlets
    
    @IBOutlet weak var profileView: UIView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var addImageButton: UIButton!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var birthTextField: UITextField!
    
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
    private let bioTextViewPlaceholder = "RoadChats #1 Fan"

    private var sex: SexType?
    
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
        
        messageTextView.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
        profileView.addGestureRecognizer(tapGestureRecognizer)
        
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
        birthTextField.inputView = datePickerView
        
        if let birth = user.profile?.birth {
            birthTextField.text = dateFormatter.string(from: birth)
        }
        
        usernameTextField.text = user.username
        
        if let biography = user.profile?.biography {
            bioTextView.text = biography
        } else {
            bioTextView.text = bioTextViewPlaceholder
        }
        
        if let firstName = user.profile?.firstName, let lastName = user.profile?.lastName {
            firstNameTextField.text = firstName
            lastNameTextField.text = lastName
        }
    
        sex = user.profile?.storedSex
        
        switch sex {
        case .male?:
            maleView.backgroundColor = colorPalette.maleColor
        case .female?:
            femaleView.backgroundColor = colorPalette.femaleColor
        case .other?:
            genderQueerView.backgroundColor = colorPalette.otherColor
        default:
            return
        }
        
        if let streetName = user.profile?.streetName, let streetNumber = user.profile?.streetNumber, let postalCode = user.profile?.postalCode, let country = user.profile?.country {
            streetNameTextField.text = streetName
            streetNumberTextField.text = String(streetNumber)
            postalCodeTextField.text = String(postalCode)
            countryTextField.text = country
        }
    }
    
    // MARK: - Public Methods
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        guard let birthString = birthTextField.text, let birth = dateFormatter.date(from: birthString), let _ = usernameTextField.text, let biography = bioTextView.text, let firstName = firstNameTextField.text, let lastName = lastNameTextField.text, let streetName = streetNameTextField.text, let streetNumberString = streetNumberTextField.text, let streetNumber = Int(streetNumberString), let postalCodeString = postalCodeTextField.text, let postalCode = Int(postalCodeString), let city = cityTextField.text, let country = countryTextField.text else {
            return
        }
        
        let profileRequest = ProfileRequest(firstName: firstName, lastName: lastName, birth: birth, sex: sex, biography: biography, streetName: streetName, streetNumber: streetNumber, postalCode: postalCode, city: city, country: country)
        
        user.createOrUpdateProfile(profileRequest) { error in
            guard error == nil else {
                self.displayAlert(title: "Error", message: "Failed to create profile: \(error!)")
                return
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func didChangeBirthDate(sender: UIDatePicker) {
        birthTextField.textColor = colorPalette.textColor
        
        // get the date string applied date format
        let selectedDate = dateFormatter.string(from: sender.date)
        birthTextField.text = selectedDate
    }
    
    @IBAction func didPressAddImageButton(_ sender: UIButton) {
        // TODO
    }
    
    @IBAction func didPressMaleButton(_ sender: UIButton) {
        sex = .male
        maleView.backgroundColor = UIColor.lightGray
        femaleView.backgroundColor = UIColor.white
        genderQueerView.backgroundColor = UIColor.white
    }
    
    @IBAction func didPressGenderQueerButton(_ sender: UIButton) {
        sex = .other
        maleView.backgroundColor = UIColor.white
        femaleView.backgroundColor = UIColor.white
        genderQueerView.backgroundColor = UIColor.lightGray
    }
    
    @IBAction func didPressFemaleButton(_ sender: UIButton) {
        sex = .female
        maleView.backgroundColor = UIColor.white
        femaleView.backgroundColor = UIColor.lightGray
        genderQueerView.backgroundColor = UIColor.white
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == bioTextView, textView.text == bioTextViewPlaceholder {
            textView.text = ""
            textView.textColor = colorPalette.textColor
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == messageTextView, textView.text.count == 0 {
            textView.textColor = colorPalette.lightTextColor
            textView.text = bioTextViewPlaceholder
        }
    }

}
