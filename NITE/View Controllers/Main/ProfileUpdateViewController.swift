//
//  ProfileUpdateViewController.swift
//  NITE
//
//  Created by Charles Oxendine on 4/17/22.
//

import UIKit
import FirebaseAuth

struct profileUpdateData {
    var avatarImage: UIImage?
    var profilePictures: [UIImage]?
    var firstName: String?
    var lastName: String?
    var description: String?
    var genderIdentity: Int?
    var genderPreferences: Int?
}

enum ProfileFields: Int {
    case imagesField
    case description
    case genderIdentity
    case genderPreferences
    case firstName
    case lastName
}

class ProfileUpdateViewController: UIViewController {

    private let fieldCaptions = ["IMAGE", "Description", "Gender Identity", "Gender Preferences", "First Name", "Last Name"]
    private let placeholders = ["IMAGE", "Description", "Gender Identity", "Who do you want to match with?", "Jane", "Doe"]
    private let fieldKeyboardTypes: [UIKeyboardType] = [.default, .default, .default, .numberPad, .default, .default]
    
    @IBOutlet weak var tableView: UITableView!
    var footerView: singleButtonFooterView?
    
    var newData: profileUpdateData?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        self.footerView = Bundle.main.loadNibNamed("singleButtonFooterView", owner: self, options: nil)?.first as? singleButtonFooterView
        footerView?.delegate = self
        footerView?.autoresizingMask = []
        tableView.tableFooterView = footerView
        
        ["FieldEntryTableViewCell", "addImagesTableViewCell"].forEach( {
            tableView.register(UINib.init(nibName: $0, bundle: nil), forCellReuseIdentifier: $0)
        })
        
        setHeader()
        setExistingProfileData()
    }
    
    func setExistingProfileData() {
        guard let user = FirebaseServices.shared.getCurrentUserProfile() else {
            return
        }
        
        let data = profileUpdateData(avatarImage: nil, profilePictures: nil, firstName: user.firstName, lastName: user.lastName, description: user.description, genderIdentity: user.genderIdentity?.rawValue, genderPreferences: user.genderPreference?.rawValue)
        self.newData = data
        self.tableView.reloadData()
    }
    
    func setHeader() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        navBarAppearance.backgroundColor = .white
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.themeBlueGray(), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25)]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.themeBlueGray(), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25)]
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.standardAppearance = navBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        self.title = "Update Profile"

        setNavBarButtons()
    }
    
    private func setNavBarButtons() {
        var configuration = UIButton.Configuration.filled()
        configuration.imagePadding = -10
        configuration.baseBackgroundColor = .clear
        configuration.baseForegroundColor = .themeBlueGray()
        
        let profileButton = UIButton(type: .custom)
        let profileIcon = UIImage(systemName: "arrow.left")!
        configuration.image = profileIcon
        profileButton.configuration = configuration
        profileButton.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileButton)
    }
    
    func setExistingData(index: Int, cell: FieldEntryTableViewCell) {
        switch index {
        case ProfileFields.firstName.rawValue:
            cell.textField.text = self.newData?.firstName ?? ""
        case ProfileFields.lastName.rawValue:
            cell.textField.text = self.newData?.lastName ?? ""
        case ProfileFields.description.rawValue:
            cell.textField.text = self.newData?.description ?? ""
        case ProfileFields.genderIdentity.rawValue:
            cell.textField.text = GenderIdentity(rawValue: self.newData?.genderIdentity ?? 0)?.getGenderIdentityName()
        case ProfileFields.genderPreferences.rawValue:
            cell.textField.text = GenderPreference(rawValue: self.newData?.genderPreferences ?? 0)?.getGenderPreferenceName()
        default:
            print("Fatal Error")
        }
    }
    
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ProfileUpdateViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fieldCaptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == ProfileFields.imagesField.rawValue {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "addImagesTableViewCell", for: indexPath) as? addImagesTableViewCell {
                cell.delegate = self
                cell.cellImages = self.newData?.profilePictures ?? []
                return cell
            }
        }
          
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FieldEntryTableViewCell", for: indexPath) as? FieldEntryTableViewCell {
            cell.captionLabel.text = fieldCaptions[indexPath.row]
            cell.textField.placeholder = placeholders[indexPath.row]
        
            cell.textField.delegate = self
            cell.textField.tag = indexPath.row
            
            self.setExistingData(index: indexPath.row, cell: cell)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == ProfileFields.imagesField.rawValue {
            return 160
        }
        
        return 70
    }
}

extension ProfileUpdateViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case ProfileFields.firstName.rawValue:
            self.newData?.firstName = textField.text
        case ProfileFields.lastName.rawValue:
            self.newData?.lastName = textField.text
        case ProfileFields.description.rawValue:
            self.newData?.description = textField.text
        default:
            print("Default")
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField.tag {
        case ProfileFields.genderIdentity.rawValue:
            textField.resignFirstResponder()
            let storyboard = UIStoryboard(name: "Utility", bundle: nil)
            if let newVC = storyboard.instantiateViewController(withIdentifier: "GenderIdentityViewController") as? GenderIdentityViewController {
                newVC.delegate = self
                self.navigationController?.pushViewController(newVC, animated: true)
            }
        case ProfileFields.genderPreferences.rawValue:
            textField.resignFirstResponder()
            let storyboard = UIStoryboard(name: "Utility", bundle: nil)
            if let newVC = storyboard.instantiateViewController(withIdentifier: "GenderPrefSelectionViewController") as? GenderPrefSelectionViewController {
                newVC.delegate = self
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

extension ProfileUpdateViewController: singleButtonFooterViewDelegate {
    func didTapButton() {
        self.view.endEditing(true)
        self.showLoadingIndicator()
        
        guard newData?.genderPreferences != nil &&
                newData?.genderIdentity != nil &&
                newData?.firstName != nil &&
                newData?.lastName != nil else {
                    self.showErrorMessage(message: "Please fill in all required fields.")
                    self.removeLoadingIndicator()
                    return
                }
        
        var originalUserProfile = FirebaseServices.shared.getCurrentUserProfile()
        originalUserProfile?.firstName = newData?.firstName
        originalUserProfile?.lastName = newData?.lastName
        originalUserProfile?.genderIdentity = GenderIdentity(rawValue: (newData?.genderIdentity)!)
        originalUserProfile?.genderPreference = GenderPreference(rawValue:  (newData?.genderPreferences)!)
        originalUserProfile?.description = newData?.description ?? ""
        
        guard let uid = Auth.auth().currentUser?.uid else {
            self.removeLoadingIndicator()
            return
        }
        
        FirebaseServices.shared.updateDataBaseUserProfile(_withUID: uid, updatedProfileData: originalUserProfile!) { error in
            if let error = error {
                self.showErrorMessage(message: error.errorMsg)
                self.removeLoadingIndicator()
                return
            }
            
            self.removeLoadingIndicator()
            self.showOkMessage(title: "Success", message: "Profile Updated") {
                print("Done")
            }
        }
    }
}

extension ProfileUpdateViewController: addImagesTableViewCellDelegate {
    func didTapAddImageCell() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.mediaTypes = ["public.image", "public.movie"]
        pickerController.sourceType = .photoLibrary
        self.present(pickerController, animated: true)
    }
    
    func didTapImageCell(image: UIImage?) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        guard let image = image else {
            self.newData?.profilePictures?.append(image!)
            let index = IndexPath(row: ProfileFields.imagesField.rawValue, section: 0)
            self.tableView.reloadRows(at: [index], with: .fade)
            return
        }
    
        let deleteAction = UIAlertAction(title: "Delete Image", style: .destructive) { (action) in
            // DELETE
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }
        
        deleteAction.setValue(UIColor.themeBlueGray(), forKey: "titleTextColor")
        cancelAction.setValue(UIColor.themeBlueGray(), forKey: "titleTextColor")
        
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
}

extension ProfileUpdateViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            picker.dismiss(animated: true)
            if newData?.profilePictures == nil {
                newData?.profilePictures = []
            }
            
            self.newData?.profilePictures!.append(image)
            let indexPath = IndexPath(item: 0, section: 0)
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
}

extension ProfileUpdateViewController: GenderIdentityViewControllerDelegate {
    func didSelect(gender: GenderIdentityButtons) {
        self.newData?.genderIdentity = gender.rawValue
        let indexPath = IndexPath(row: ProfileFields.genderIdentity.rawValue, section: 0)
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
}

extension ProfileUpdateViewController: GenderPrefSelectionViewControllerDelegate {
    func didSelect(gender: Int) {
        self.newData?.genderPreferences = gender
        let indexPath = IndexPath(row: ProfileFields.genderPreferences.rawValue, section: 0)
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
}
