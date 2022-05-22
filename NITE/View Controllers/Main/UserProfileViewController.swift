//
//  UserProfileViewController.swift
//  NITE
//
//  Created by Charles Oxendine on 5/21/22.
//

import UIKit

class UserProfileViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let sectionTitles = ["Images"]
    
    var profileUserObj: PublicUserProfile?
    var footerView: singleButtonFooterView?
    var profileImages: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        self.footerView = Bundle.main.loadNibNamed("singleButtonFooterView", owner: self, options: nil)?.first as? singleButtonFooterView
        footerView?.delegate = self
        footerView?.autoresizingMask = []
        tableView.tableFooterView = footerView
        
        ["addImagesTableViewCell"].forEach( {
            tableView.register(UINib.init(nibName: $0, bundle: nil), forCellReuseIdentifier: $0)
        })
        
        setHeader()
        checkMatchDateForImages()
    }
    
    private func checkMatchDateForImages() {
        guard let otherUserUID = self.profileUserObj?.id,
              let currentUserUID = FirebaseServices.shared.getCurrentUserProfile()?.id else {
            return
        }
        
        FirebaseServices.shared.getMatchData(userID1: otherUserUID, userID2: currentUserUID) { matchObject in
            if matchObject?.matchDate.dateValue() ?? Date() < Date().advanced(by: -259200) {
                self.getProfileImages(showingPics: true)
            } else {
                self.getProfileImages(showingPics: false)
            }
        }
    }
    
    private func getProfileImages(showingPics: Bool) {
        guard let userObj = self.profileUserObj else {
            return
        }
        
        if showingPics == true {
            self.setOnlyAvatar(avatarLocation: self.profileUserObj?.avatarImageLocation ?? "")
        } else {
            FirebaseServices.shared.getUserProfileImages(_withUID: userObj.id, _withImageIDs: userObj.imageLocations ?? []) { error, images in
                var profileImages: [taggedImageObject] = images ?? []
                if let avatarURL = URL(string: FirebaseServices.shared.getCurrentUserProfile()?.avatarImageLocation ?? "") {
                    let data = try? Data(contentsOf: avatarURL)
                    let avatarImage = UIImage(data: data!)
                    let taggedIMG = taggedImageObject(url: avatarURL.absoluteString, image: avatarImage)
                    profileImages.insert(taggedIMG, at: 0)
                }
                
                var formattedProfileImages: [UIImage] = []
                for images in profileImages {
                    formattedProfileImages.append(images.image)
                }
                
                self.profileImages = formattedProfileImages
                self.tableView.reloadData()
            }
        }
    }
    
    private func setOnlyAvatar(avatarLocation: String) {
        if let avatarURL = URL(string: avatarLocation) {
            let data = try? Data(contentsOf: avatarURL)
            if let avatarImage = UIImage(data: data!) {
                self.profileImages = [avatarImage]
                self.tableView.reloadData()
            }
        }
    }
    
    private func setHeader() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        navBarAppearance.backgroundColor = .white
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.standardAppearance = navBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        self.title = "Profile"

        setNavBarButtons()
    }
    
    private func setNavBarButtons() {
        var configuration = UIButton.Configuration.filled()
        configuration.imagePadding = -10
        configuration.baseBackgroundColor = .clear
        configuration.baseForegroundColor = .themeBlueGray()
        
        let backButton = UIButton(type: .custom)
        let backIcon = UIImage(systemName: "arrow.left")!
        configuration.image = backIcon
        backButton.configuration = configuration
        backButton.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    @objc private func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension UserProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == ProfileFields.imagesField.rawValue {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "addImagesTableViewCell", for: indexPath) as? addImagesTableViewCell {
                cell.delegate = self
                cell.cellImages = self.profileImages
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == ProfileFields.imagesField.rawValue {
            return 300
        }
        
        return 70
    }
}

extension UserProfileViewController: singleButtonFooterViewDelegate {
    func didTapButton() {
        // UNADD USER
    }
}

extension UserProfileViewController: addImagesTableViewCellDelegate {
    func didTapAddImageCell() {
        print("[ALERT] This shouldn't be happening...")
    }
    
    func didTapImageCell(image: taggedImageObject?) {
        // SHOW IN FULL SCREEN
    }
}
