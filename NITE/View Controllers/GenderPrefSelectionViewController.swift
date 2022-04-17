//
//  GenderPrefSelectionViewController.swift
//  NITE
//
//  Created by Charles Oxendine on 4/17/22.
//

import UIKit

protocol GenderPrefSelectionViewControllerDelegate {
    func didSelect(gender: Int)
}

enum GenderPrefButtons: Int {
    case Male
    case Female
    case MaleFemale
    case Everyone
}

class GenderPrefSelectionViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var delegate: GenderPrefSelectionViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        setHeader()
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
        self.title = "Gender Identity"

        setNavBarButtons()
    }
    
    private func setNavBarButtons() {
        var configuration = UIButton.Configuration.filled()
        configuration.imagePadding = -10
        configuration.baseBackgroundColor = .clear
        configuration.baseForegroundColor = .themeBlueGray()
        
        let backButton = UIButton(type: .custom)
        let profileIcon = UIImage(systemName: "arrow.left")!
        configuration.image = profileIcon
        backButton.configuration = configuration
        backButton.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension GenderPrefSelectionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "id")
        
        cell.textLabel?.text = GenderPreference(rawValue: indexPath.row)?.getGenderPreferenceName()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelect(gender: indexPath.row)
        self.navigationController?.popViewController(animated: true)
    }
}
