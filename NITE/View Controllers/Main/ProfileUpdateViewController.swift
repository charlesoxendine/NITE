//
//  ProfileUpdateViewController.swift
//  NITE
//
//  Created by Charles Oxendine on 4/17/22.
//

import UIKit
import FirebaseAuth
import SCSDKLoginKit
import ViewAnimator

struct ProfileUpdateData {
    var avatarImage: UIImage?
    var profilePictures: [TaggedImageObject]?
    var firstName: String?
    var lastName: String?
    var description: String?
    var genderIdentity: Int?
    var genderPreferences: Int?
}

enum ProfileFields: Int {
    case imagesField
    case snapchatLoginManager
    case description
    case genderIdentity
    case genderPreferences
    case firstName
    case lastName
}

class ProfileUpdateViewController: UIViewController {

    private let fieldCaptions = ["IMAGE", "SNAPCHAT MANAGER", "Description", "Gender Identity", "Gender Preferences", "First Name", "Last Name"]
    private let placeholders = ["IMAGE", "SNAPCHAT MANAGER", "Description", "Gender Identity", "Who do you want to match with?", "Jane", "Doe"]
    private let fieldKeyboardTypes: [UIKeyboardType] = [.default, .default, .default, .numberPad, .default, .default]
    
    @IBOutlet weak var tableView: UITableView!
    var footerView: SingleButtonFooterView?
    
    var newData: ProfileUpdateData?
    var newImages: [UIImage] = []
    var deletedURLs: [String] = []
    var avatarImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        self.footerView = Bundle.main.loadNibNamed("singleButtonFooterView", owner: self, options: nil)?.first as? SingleButtonFooterView
        footerView?.delegate = self
        footerView?.autoresizingMask = []
        tableView.tableFooterView = footerView
        
        ["FieldEntryTableViewCell", "addImagesTableViewCell", "AddSnapchatTableViewCell"].forEach( {
            tableView.register(UINib.init(nibName: $0, bundle: nil), forCellReuseIdentifier: $0)
        })
        
        setHeader()
        setExistingProfileData()
        setCurrentStoredUserProfiles()
    }
    
    func setExistingProfileData() {
        guard let user = FirebaseServices.shared.getCurrentUserProfile() else {
            return
        }
        
        let data = ProfileUpdateData(avatarImage: nil,
                                     profilePictures: nil,
                                     firstName: user.firstName,
                                     lastName: user.lastName,
                                     description: user.description,
                                     genderIdentity: user.genderIdentity?.rawValue,
                                     genderPreferences: user.genderPreference?.rawValue)
        self.newData = data
        self.tableView.reloadData()
    }
    
    func setCurrentStoredUserProfiles() {
        if let uid = Auth.auth().currentUser?.uid {
            FirebaseServices.shared.getUserProfileImages(_withUID: uid, _withImageIDs: FirebaseServices.shared.getCurrentUserProfile()?.imageLocations ?? []) { error, images in
                var profileImages: [TaggedImageObject] = images ?? []
                if let avatarURL = URL(string: FirebaseServices.shared.getCurrentUserProfile()?.avatarImageLocation ?? "") {
                    let data = try? Data(contentsOf: avatarURL) // make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    let avatarImage = UIImage(data: data!)
                    let taggedIMG = TaggedImageObject(url: avatarURL.absoluteString, image: avatarImage)
                    self.avatarImage = avatarImage
                    profileImages.insert(taggedIMG, at: 0)
                }
                
                self.newData?.profilePictures = profileImages
                self.tableView.reloadData()
            }
        }
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
        
        let avatarEditButton = UIButton(type: .custom)
        let avatarIcon = UIImage(systemName: "power")!
        configuration.image = avatarIcon
        avatarEditButton.configuration = configuration
        avatarEditButton.addTarget(self, action: #selector(self.logoutTapped), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: avatarEditButton)
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
            if let genderIdentityInt = self.newData?.genderIdentity {
                cell.textField.text = GenderIdentity(rawValue: genderIdentityInt)?.getGenderIdentityName()
            } else {
                cell.textField.text = ""
            }
        case ProfileFields.genderPreferences.rawValue:
            if let genderPrefInt = self.newData?.genderPreferences {
                cell.textField.text = GenderPreference(rawValue: genderPrefInt)?.getGenderPreferenceName()
            } else {
                cell.textField.text = ""
            }
        default:
            print("Fatal Error")
        }
    }
    
    @objc func logoutTapped() {
        let alert = UIAlertController(title: "Are you sure?", message: "", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Logout", style: .default) { action in
            try? Auth.auth().signOut()
            FirebaseServices.shared.setCurrentUserProfile(profile: nil)
            
            let storyboard = UIStoryboard(name: "Auth", bundle: nil)
            let newVC = storyboard.instantiateViewController(withIdentifier: "main")
            newVC.modalPresentationStyle = .fullScreen
            self.present(newVC, animated: true)
        }
        
        let goBackAction = UIAlertAction(title: "Close", style: .default)
        
        alert.addAction(goBackAction)
        alert.addAction(confirmAction)
        self.present(alert, animated: true)
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
            if let cell = tableView.dequeueReusableCell(withIdentifier: "addImagesTableViewCell", for: indexPath) as? AddImagesTableViewCell {
                cell.delegate = self
                cell.cellImagesTagged = self.newData?.profilePictures ?? []
                cell.imageView?.contentMode = .scaleAspectFit
                return cell
            }
        } else if indexPath.row == ProfileFields.snapchatLoginManager.rawValue {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "AddSnapchatTableViewCell", for: indexPath) as? AddSnapchatTableViewCell {
                cell.delegate = self
                cell.avatarView.image = self.avatarImage
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
            return 300
        }
        
        if indexPath.row == ProfileFields.snapchatLoginManager.rawValue {
            return 100
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
            textField.endEditing(true)
            let storyboard = UIStoryboard(name: "Utility", bundle: nil)
            if let newVC = storyboard.instantiateViewController(withIdentifier: "GenderIdentityViewController") as? GenderIdentityViewController {
                newVC.delegate = self
                self.navigationController?.pushViewController(newVC, animated: true)
            }
        case ProfileFields.genderPreferences.rawValue:
            textField.endEditing(true)
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
    func termsTapped() {
        if let url = URL(string: "https://sites.google.com/view/nite-terms-of-service/home"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
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
        originalUserProfile?.genderPreference = GenderPreference(rawValue: (newData?.genderPreferences)!)
        originalUserProfile?.description = newData?.description ?? ""
        
        guard let uid = Auth.auth().currentUser?.uid else {
            self.removeLoadingIndicator()
            return
        }
        
        var taggedImageObjects: [TaggedImageObject] = []
        for imageObj in newImages {
            let taggedObj = TaggedImageObject(image: imageObj)
            taggedImageObjects.append(taggedObj)
        }
        
        self.newData?.profilePictures = taggedImageObjects
        
        var newProfileImages: [UIImage] = []
        for image in self.newData?.profilePictures ?? [] {
            newProfileImages.append(image.image)
        }
        
        FirebaseServices.shared.updateDataBaseUserProfile(_withUID: uid, newProfileImages: newProfileImages, updatedProfileData: originalUserProfile!, deletedImagesURLS: self.deletedURLs) { error in
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
        pickerController.allowsEditing = false
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = .photoLibrary
        self.present(pickerController, animated: true)
    }
    
    func didTapImageCell(image: TaggedImageObject?) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        guard image != nil else {
            if self.newData?.profilePictures == nil {
                self.newData?.profilePictures = []
            }
            
            let taggedObj = TaggedImageObject(image: image?.image!)
            self.newData?.profilePictures?.append(taggedObj)
            let index = IndexPath(row: ProfileFields.imagesField.rawValue, section: 0)
            self.tableView.reloadRows(at: [index], with: .fade) 
            return
        }
    
        let deleteAction = UIAlertAction(title: "Delete Image", style: .destructive) { (action) in
            // DELETE
            self.newData?.profilePictures?.removeAll(where: { $0.url == image?.url })
            self.deletedURLs.append(image?.url ?? "")
            self.tableView.reloadData()
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            picker.dismiss(animated: true)
            
            if newData?.profilePictures == nil {
                newData?.profilePictures = []
            }
            
            let taggedObj = TaggedImageObject(image: image)
            
            self.newData?.profilePictures!.append(taggedObj)
            self.newImages.append(image)
            let indexPath = IndexPath(item: 0, section: 0)
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
}

extension ProfileUpdateViewController: GenderIdentityViewControllerDelegate {
    func didSelect(gender: GenderIdentity) {
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

extension ProfileUpdateViewController: addSnapchatTableViewCellDelegate {
    func disconnectedSnapchat() {
        print("Disconnected Snapchat")
    }
    
    func connectSnapchat() {
        if SCSDKLoginClient.isUserLoggedIn == false {
            SCSDKLoginClient.login(from: self) { (success: Bool, error: Error?) in
                self.tableView.reloadData()
            }
        } else {
            SnapchatServices.shared.getUpdatedBitmojiAvatarURL { url in
                guard let currentUser = FirebaseServices.shared.getCurrentUserProfile() else {
                    return
                }
                
                guard let url = url else {
                    return
                }

                Utils.loadImage(url: url) { image in
                    guard let image = image else {
                        return
                    }

                    FirebaseServices.shared.updateAvatarImage(_withUID: currentUser.id, avatarIMG: image) { errorStatus in
                        guard errorStatus != nil else {
                            self.showErrorMessage(message: "")
                            return
                        }
                        
                        self.showOkMessage(title: "Success", message: "Updated Avatar") {}
                    }
                }
            }
        }
    }
}
