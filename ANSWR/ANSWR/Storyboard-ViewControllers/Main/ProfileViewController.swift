//
//  ProfileViewController.swift
//  ANSWR - Code imported From Kasei
//
//  Created by Eugene L. on 24/01/21.
//

import UIKit

class ProfileViewController: CardDetailVC, UITableViewDelegate, UITableViewDataSource, ButtonCellProtocol {
    
    let authHandler = FirAuthHandler.self
    var profileDetails: ProfileDetails?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        cardTitle.text = NSLocalizedString("Profile", comment: "")
        
        cardTableView.delegate = self
        cardTableView.dataSource = self
        ProfileDetailsCell.register(for: cardTableView)
        ButtonCell.register(withReuseId: "signOutCell", for: cardTableView)
        
        UserDetailsHandler.retrieveProfileDetails { (details) in
            self.profileDetails = details
            self.cardTableView.reloadData()
        }
    }
    
    func handleSignOut() {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: {
            if let rootVC = UIApplication.shared.windows.first!.rootViewController {
                FirAuthHandler.signout()
                FirAuthHandler.presentSignin(over: rootVC)
            }
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if let cell = ProfileDetailsCell.buildInstance(for: cardTableView) {
                let defaultText = NSLocalizedString("Loading...", comment: "")
                cell.nameLabel.text = profileDetails?.name ?? defaultText
                cell.emailLabel.text = profileDetails?.email ?? defaultText
                cell.zoneLabel.text = profileDetails?.zones.joined(separator: ", ") ?? defaultText
                
                return cell
            } else {
                return UITableViewCell()
            }
        case 1:
            if let cell = ButtonCell.buildInstance(withReuseId: "signOutCell", for: cardTableView, delegate: self) {
                cell.btn.backgroundColor = UIColor(named: "Destructive")
                cell.btn.setTitleColor(UIColor(named: "Destructive Text"), for: .normal)
                cell.btn.setTitle(NSLocalizedString("Sign Out", comment: ""), for: .normal)
                return cell
            } else {
                return UITableViewCell()
            }
        default:
            return UITableViewCell()
        }
    }
    
    func buttonClicked(reuseId: String) {
        switch reuseId {
        case "signOutCell":
            handleSignOut()
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
