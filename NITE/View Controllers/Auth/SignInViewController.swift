//
//  SignInViewController.swift
//  NITE
//
//  Created by Charles Oxendine on 5/11/22.
//

import UIKit

private enum SignInField: Int {
    case email
    case password
}

struct SignInData {
    var email: String?
    var password: String?
}

class SignInViewController: UIViewController {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private var newData = SignInData()
    private var footerView: SingleButtonFooterView?
    
    private let fieldCaptions = ["Email", "Password"]
    private let placeholders = ["email@domain.com", "Password"]
    private let fieldKeyboardTypes: [UIKeyboardType] = [.emailAddress, .default]
    
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
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        tableView.contentInset = .zero
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
    }
}

extension SignInViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fieldCaptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FieldEntryTableViewCell", for: indexPath) as? FieldEntryTableViewCell {
            cell.captionLabel.text = fieldCaptions[indexPath.row]
            cell.textField.placeholder = placeholders[indexPath.row]
            
            if indexPath.row == SignInField.password.rawValue {
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

extension SignInViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case SignInField.email.rawValue:
            newData.email = textField.text
        case SignInField.password.rawValue:
            newData.password = textField.text
        default:
            return
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension SignInViewController: singleButtonFooterViewDelegate {
    func termsTapped() {
        if let url = URL(string: "https://sites.google.com/view/nite-terms-of-service/home"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func didTapButton() {
        self.view.endEditing(true)
        self.showLoadingIndicator()
        
        guard let emailStr = self.newData.email,
              let passwordStr = self.newData.password else {
            self.showErrorMessage(message: "Please fill in all fields.")
            self.removeLoadingIndicator()
            return
        }
    
        FirebaseServices.shared.loginUser(email: emailStr, password: passwordStr) { error, successfullyAuthenticated in
            self.removeLoadingIndicator()
            
            if let error = error {
                self.showErrorMessage(message: error.errorMsg)
            }
            
            if successfullyAuthenticated == true {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let newVC = storyboard.instantiateViewController(withIdentifier: "MainNav")
                newVC.modalPresentationStyle = .fullScreen
                self.navigationController?.present(newVC, animated: true)
            }
        }
    }
}
