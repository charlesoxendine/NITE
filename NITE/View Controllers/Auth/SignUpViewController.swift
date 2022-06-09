//
//  SignUpViewController.swift
//  NITE
//
//  Created by Charles Oxendine on 4/16/22.
//

import UIKit

private enum SignupField: Int {
    case firstName
    case lastName
    case email
    case genderIdentity
    case genderPreference
    case password
    case confirmPassword
}

struct SignUpData {
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
    
    private var newData = SignUpData()
    
    var footerView: SingleButtonFooterView?
    
    private let fieldCaptions = ["First name", "Last name", "Email", "Gender Identity", "Gender Preference", "Password", "Confirm password"]
    private let placeholders = ["Jane", "Doe", "email@email.com", "Gender Identity", "Who do you want to match with?", "Password", "Confirm Password"]
    private let fieldKeyboardTypes: [UIKeyboardType] = [.default, .default, .emailAddress, .numberPad, .numberPad, .default, .default, .default]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.footerView = Bundle.main.loadNibNamed("singleButtonFooterView", owner: self, options: nil)?.first as? SingleButtonFooterView
        footerView?.delegate = self
        footerView?.autoresizingMask = []
        tableView.tableFooterView = footerView
        
        ["FieldEntryTableViewCell"].forEach( {
            tableView.register(UINib.init(nibName: $0, bundle: nil), forCellReuseIdentifier: $0)
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        setUI()
    }
    
    func setUI() {
        cancelButton.setTitleColor(.themeBlueGray(), for: .normal)
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        tableView.contentInset = .zero
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
            
            if indexPath.row == SignupField.genderPreference.rawValue {
                switch self.newData.genderPreference {
                case .male:
                    cell.textField.text = "Men"
                case .female:
                    cell.textField.text = "Women"
                case .maleFemale:
                    cell.textField.text = "Women & Men"
                case .everyone:
                    cell.textField.text = "Everyone"
                default:
                    cell.textField.text = ""
                }
            }
            
            if indexPath.row == SignupField.genderIdentity.rawValue {
                switch self.newData.genderIdentity {
                case .male:
                    cell.textField.text = "Male"
                case .female:
                    cell.textField.text = "Female"
                case .other:
                    cell.textField.text = "Other"
                default:
                    cell.textField.text = ""
                }
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
            newData.genderIdentity = GenderIdentity(rawValue: Int(textField.text ?? "") ?? 0)
        case SignupField.genderPreference.rawValue:
            newData.genderPreference = GenderPreference(rawValue: Int(textField.text ?? "") ?? 0)
        case SignupField.password.rawValue:
            newData.password = textField.text
        case SignupField.confirmPassword.rawValue:
            newData.confirmPassword = textField.text
        default:
            return
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField.tag {
        case SignupField.genderIdentity.rawValue:
            textField.resignFirstResponder()
            let storyboard = UIStoryboard(name: "Utility", bundle: nil)
            if let newVC = storyboard.instantiateViewController(withIdentifier: "GenderIdentityViewController") as? GenderIdentityViewController {
                newVC.delegate = self
                newVC.fromSignUp = true
                self.navigationController?.pushViewController(newVC, animated: true)
            }
        case SignupField.genderPreference.rawValue:
            textField.resignFirstResponder()
            let storyboard = UIStoryboard(name: "Utility", bundle: nil)
            if let newVC = storyboard.instantiateViewController(withIdentifier: "GenderPrefSelectionViewController") as? GenderPrefSelectionViewController {
                newVC.delegate = self
                newVC.fromSignUp = true
                self.navigationController?.pushViewController(newVC, animated: true)
            }
        default:
            return
        }
    }
    
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
        
        let newProfile = PublicUserProfile(id: UUID().uuidString,
                                           firstName: self.newData.firstName,
                                           lastName: self.newData.lastName,
                                           description: nil,
                                           imageLocations: nil,
                                           avatarImageLocation: nil,
                                           interests: nil,
                                           geohash: nil,
                                           lat: nil,
                                           long: nil)
        
        self.showLoadingIndicator()
        FirebaseServices.shared.createUser(email: emailStringCleaned, password: self.newData.password!, newProfileData: newProfile) { error in
            self.removeLoadingIndicator()
            
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

extension SignUpViewController: GenderIdentityViewControllerDelegate {
    func didSelect(gender: GenderIdentity) {
        self.newData.genderIdentity = gender
        let indexPath = IndexPath(row: SignupField.genderIdentity.rawValue, section: 0)
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
}

extension SignUpViewController: GenderPrefSelectionViewControllerDelegate {
    func didSelect(gender: Int) {
        self.newData.genderPreference = GenderPreference(rawValue: gender)
        let indexPath = IndexPath(row: SignupField.genderPreference.rawValue, section: 0)
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
}
