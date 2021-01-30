//
//  LandingViewController.swift
//  ANSWR - Code imported From Kasei
//
//  Created by Eugene L. on 24/01/21.
//

import UIKit
import FirebaseDatabase

class LandingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TasksheetProtocol {

    @IBOutlet weak var noRequestLabel: UILabel!
    @IBOutlet weak var resultCard: UIView!
    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var resultFlavourText: UILabel!
    @IBOutlet weak var resultActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var requestTableView: UITableView!
    let refreshControl = UIRefreshControl()
    
    var zoneRequests = Array<ZoneRequests>() {
        didSet {
            if zoneRequests.count > 0 {
                noRequestLabel.isHidden = true
            } else {
                noRequestLabel.isHidden = false
            }
        }
    }
    
    let DBRef = Database.database().reference()
    let authHandler = FirAuthHandler.self
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        requestTableView.delegate = self
        requestTableView.dataSource = self
        requestTableView.addSubview(noRequestLabel)
        requestTableView.sendSubviewToBack(noRequestLabel)

        requestTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(objcRefreshData(_:)), for: .valueChanged)
        
        RequestDetailCell.register(for: requestTableView)

        // Preload saved requests from core data
        zoneRequests = CDHandler.loadAllZoneRequests()
        requestTableView.reloadData()
        
        // Then attempt to update from server
        refreshData()
    }
    
    @objc private func objcRefreshData(_ sender: Any) {
        refreshData()
    }
    
    func refreshData() {
        fetchAllZoneRequests { (zonerequests) in
            let newZoneReqs = zonerequests
            
            // update and reload core data
            CDHandler.updateSavedRequests(newZoneRequests: newZoneReqs)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self.zoneRequests = CDHandler.loadAllZoneRequests()
                self.requestTableView.reloadData()
                if (self.refreshControl.isRefreshing) {
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    func fetchAllZoneRequests(onComplete: @escaping ([ZoneRequests])->()) {
        UserDetailsHandler.retrieveZones { (zones, uid) in
            guard zones != nil && uid != nil else {
                return
            }
            
            var zoneRequestsArr = [ZoneRequests]()
            var counter = zones!.count
            for zone in zones! {
                getZoneRequests(DBRef: self.DBRef, for: zone) { (zonereq) in
                    if let zr = zonereq {
                        zoneRequestsArr.append(zr);
                    }
                    counter -= 1
                    if counter == 0 {
                        onComplete(zoneRequestsArr)
                    }
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return zoneRequests.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return zoneRequests[section].zoneid
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return zoneRequests[section].requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //TODO: always load request summary cell
        let zoneid = zoneRequests[indexPath.section].zoneid
        let request = zoneRequests[indexPath.section].requests[indexPath.row]
        if let cell = RequestDetailCell.buildInstance(for: requestTableView, request: request) {
            cell.zoneid = zoneid
            cell.delegate = self
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    // method imported from https://stackoverflow.com/questions/39268477/how-to-calculate-textview-height-base-on-text
    // created by https://stackoverflow.com/users/5901353/d-greg
    func calculatedHeight(for text: String, width: CGFloat) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width,
                                          height: .greatestFiniteMagnitude))
        label.font = UIFont(name: "Avenir Next Medium", size: 16)
        label.numberOfLines = 0
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let request = zoneRequests[indexPath.section].requests[indexPath.row]
        let width = self.view.frame.width - 80
        let addressHeight = calculatedHeight(for: request.elderlyAddressString!, width: width)
        let layoutMarginPadding: CGFloat = 22
        let finalHeight =  223 + addressHeight + CGFloat((request.items.count * 30)) + layoutMarginPadding
        return finalHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.systemBackground
    }
    
    @IBAction func clickedProfileBtn(_ sender: Any) {
        present(ProfileViewController(nibName: "CardDetailVC", bundle: nil), animated: true, completion: nil)
    }
    
    func reloadTasksheet() {
        refreshData()
    }
    
    func showResultCard() {
        resultCard.isHidden = false
        resultActivityIndicator.startAnimating()
        resultFlavourText.text = "Updating..."
    }
    
    func showResult(success: Bool) {
        resultActivityIndicator.stopAnimating()
        resultImageView.isHidden = false
        if success {
            resultImageView.image = UIImage(systemName: "checkmark.circle.fill")
            resultImageView.tintColor = UIColor(named: "Accent Static")
            resultFlavourText.text = "Success"
        } else {
            resultImageView.image = UIImage(systemName: "xmark.circle.fill")
            resultImageView.tintColor = UIColor(named: "Destructive")
            resultFlavourText.text = "Something went wrong!"
        }
    }
    
    func hideResult() {
        resultImageView.isHidden = true
        resultCard.isHidden = true
    }
    
    func completeRequest(req: Request, zoneid: String) {
        showResultCard()
        markRequestAsComplete(for: req, in: zoneid) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showResult(success: true)
                self.reloadTasksheet()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.hideResult()
                }
            }
        }
    }
    
    func presentAlert(alert: UIAlertController) {
        self.present(alert, animated: true, completion: nil)
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

protocol TasksheetProtocol {
    func reloadTasksheet()
    func completeRequest(req: Request, zoneid: String)
    func presentAlert(alert: UIAlertController)
}
