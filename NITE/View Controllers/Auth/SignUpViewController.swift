//
//  SignUpViewController.swift
//  NITE
//
//  Created by Charles Oxendine on 4/16/22.
//

import UIKit

fileprivate enum SignupField: Int {
    case firstName
    case lastName
    case email
    case genderIdentity
    case genderPreference
    case password
    case confirmPassword
}

struct signUpData {
    var firstName: String?
    var lastName: String?
    var email: String?
    var genderIdentity: GenderIdentity?
    var genderPreference: GenderPreference?
    var password: String?
    var confirmPassword: String?
}

class SignUpViewController: UIViewController {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private var newData = signUpData()
    
    var footerView: singleButtonFooterView?
    
    private let fieldCaptions = ["First name", "Last name", "Email", "Gender Identity", "Gender Preference", "Password", "Confirm password"]
    private let placeholders = ["Jane", "Doe", "email@email.com", "Gender Identity", "Who do you want to match with?", "Password", "Confirm Password"]
    private let fieldKeyboardTypes: [UIKeyboardType] = [.default, .default, .emailAddress, .numberPad, .numberPad, .default, .default, .default]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.footerView = Bundle.main.loadNibNamed("singleButtonFooterView", owner: self, options: nil)?.first as? singleButtonFooterView
        footerView?.delegate = self
        footerView?.autoresizingMask = []
        tableView.tableFooterView = footerView
        
        ["FieldEntryTableViewCell"].forEach( {
            tableView.register(UINib.init(nibName: $0, bundle: nil), forCellReuseIdentifier: $0)
        })
        
        setUI()
    }
    
    func setUI() {
        cancelButton.setTitleColor(.themeBlueGray(), for: .normal)
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension SignUpViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fieldCaptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FieldEntryTableViewCell", for: indexPath) as? FieldEntryTableViewCell {
            cell.captionLabel.text = fieldCaptions[indexPath.row]
            cell.textField.placeholder = placeholders[indexPath.row]
            
            if indexPath.row == SignupField.password.rawValue ||
                indexPath.row == SignupField.confirmPassword.rawValue {
                cell.textField.isSecureTextEntry = true
            } else {
                cell.textField.isSecureTextEntry = false
            }
                
            cell.textField.delegate = self
            cell.textField.tag = indexPath.row
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case SignupField.firstName.rawValue:
            newData.firstName = textField.text
        case SignupField.lastName.rawValue:
            newData.lastName = textField.text
        case SignupField.email.rawValue:
            newData.email = textField.text
        case SignupField.genderIdentity.rawValue:
            newData.genderIdentity = GenderIdentity(rawValue: Int(textField.text ?? "")!)
        case SignupField.genderPreference.rawValue:
            newData.genderPreference = GenderPreference(rawValue: Int(textField.text ?? "")!)
        case SignupField.password.rawValue:
            newData.password = textField.text
        case SignupField.confirmPassword.rawValue:
            newData.confirmPassword = textField.text
        default:
            return
        }
    }
    
    /*func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField.tag {
        case SignupField.genderPreference.rawValue:
            textField.resignFirstResponder()
        case SignupField.genderIdentity.rawValue:
            textField.resignFirstResponder()
        default:
            return
        }
    }
    */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension SignUpViewController: singleButtonFooterViewDelegate {
    
    func didTapButton() {
        self.view.endEditing(true)
        guard self.newData.firstName != nil &&
                self.newData.lastName != nil &&
                self.newData.email != nil &&
                self.newData.genderIdentity != nil &&
                self.newData.genderPreference != nil &&
                self.newData.password != nil &&
                self.newData.confirmPassword != nil else {
                    self.showErrorMessage(message: "Please fill in all fields")
                    return
                }
        
        guard let emailStringCleaned = self.newData.email?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            self.showErrorMessage(message: "Error with formatting email.")
            return
        }
        
        guard self.newData.password == self.newData.confirmPassword else {
            self.showErrorMessage(message: "Your passwords don't seem to match.")
            return
        }
        
        let newProfile = PublicUserProfile(id: UUID().uuidString, firstName: self.newData.firstName, lastName: self.newData.lastName, description: nil, imageLocations:nil, avatarImageLocation: nil, interests: nil, geohash: nil, lat: nil, long: nil)
        FirebaseServices.shared.createUser(email: emailStringCleaned, password: self.newData.password!, newProfileData: newProfile) { error in
            if let error = error {
                self.showErrorMessage(message: error.errorMsg)
                return
            }
            
            self.showOkMessage(title: "Success", message: "Your account has been created.") {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let newVC = storyboard.instantiateViewController(withIdentifier: "MainNav")
                newVC.modalPresentationStyle = .fullScreen
                self.navigationController?.present(newVC, animated: true)
            }
        }
    }
    
}
