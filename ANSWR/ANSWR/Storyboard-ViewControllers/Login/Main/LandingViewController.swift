//
//  LandingViewController.swift
//  Kasei
//
//  Created by Eugene L. on 14/11/20.
//

import UIKit
import FirebaseDatabase

class LandingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NewItemCellProtocol, RequestSummaryCellProtocol {

    @IBOutlet weak var requestTableView: UITableView!
    let refreshControl = UIRefreshControl()
    
    var userRequests = Array<Request>()
    
    let DBRef = Database.database().reference()
    let authHandler = FirAuthHandler.self
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        requestTableView.delegate = self
        requestTableView.dataSource = self

        requestTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(objcRefreshData(_:)), for: .valueChanged)
        
        NewItemCell.register(for: requestTableView)
        RequestSummaryCell.register(for: requestTableView)
        
        // Preload saved requests from core data
        userRequests = CDHandler.loadAllRequests()
        requestTableView.reloadData()
        
        // Then attempt to update from server
        refreshData()
    }
    
    @objc private func objcRefreshData(_ sender: Any) {
        refreshData()
    }
    
    func refreshData() {
        
        fetchAllUserRequests { (requests) in
            if requests != nil {
                // update saved requests
                CDHandler.updateSavedRequests(newRequests: requests!)
                
                // reload saved requests and piggyback on CDHandler to sort by dateCreated
                self.userRequests = CDHandler.loadAllRequests()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self.requestTableView.reloadData()
                if (self.refreshControl.isRefreshing) {
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    func fetchAllUserRequests(onComplete: @escaping (Array<Request>?) -> ()) {
        // fetch data from firebase
        guard let uid = authHandler.firAuth.currentUser?.uid else {
            print("No UID!")
            return
        }
        
        DBRef.child("userRequests/\(uid)").observeSingleEvent(of: .value) { (snapshot) in
            var requests = [Request]()
            
            guard snapshot.exists() else {
                onComplete(requests)
                return
            }
            
            var zoneCount = snapshot.childrenCount
            for zoneChild in snapshot.children {
                let zoneChildSnap = zoneChild as! DataSnapshot
                let zoneID = zoneChildSnap.key
                var requestCount = zoneChildSnap.childrenCount
                
                for requestsChildSnap in zoneChildSnap.children {
                    let requestIDSnap = requestsChildSnap as! DataSnapshot
                    let id = requestIDSnap.value as! String
                    
                    getRequest(DBRef: self.DBRef, forZoneID: zoneID, forID: id) { (r) in
                        if r != nil { requests.append(r!) }
                        requestCount -= 1
                        if requestCount == 0 {
                            zoneCount -= 1
                        }
                        if zoneCount == 0 && requestCount == 0 {
                            onComplete(requests)
                        }
                    }
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return userRequests.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return NewItemCell.buildInstance(for: requestTableView, delegate: self, title: NSLocalizedString("New Request", comment: "")) ?? UITableViewCell()
        case 1:
            let request = userRequests[indexPath.row]
            if let cell = RequestSummaryCell.buildInstance(for: requestTableView, delegate: self) {
                cell.statusLabel.text = StatusMap.getStatus(for: request.status!)
                cell.deliverySlotLabel.text = request.delSlotString()
                
                if request.isNew ?? false {
                    cell.isNewIndicator.isHidden = false
                } else {
                    cell.isNewIndicator.isHidden = true
                }
                
                // format contents
                var summaryStrings = [String]()
                for item in request.items {
                    summaryStrings.append("\(item.qty) \(item.name)")
                }
                let summary = summaryStrings.joined(separator: ", ")
                cell.contentSummary.text = summary
                
                return cell
            } else {
                return UITableViewCell()
            }
        default:
            return UITableViewCell()
        }
    }
    
    @IBAction func clickedProfileBtn(_ sender: Any) {
        present(ProfileViewController(nibName: "CardDetailVC", bundle: nil), animated: true, completion: nil)
    }
    
    func presentRequestStoryboard() {
        let vc = UIStoryboard(name: "Request", bundle: nil).instantiateInitialViewController()
        guard let loginVC = vc else {
            return
        }
        loginVC.modalPresentationStyle = .fullScreen
        self.present(loginVC, animated: true, completion: nil)
    }
    
    func presentDetailView(for cell: RequestSummaryCell) {
        if let indexPath = requestTableView.indexPath(for: cell) {
            let detailVC = RequestDetailViewController(nibName: "CardDetailVC", bundle: nil)
            detailVC.request = userRequests[indexPath.row]
            present(detailVC, animated: true, completion: nil)
        } else {
            print("There was an error!")
        }
    }
    
    func newItem() {
        presentRequestStoryboard()
    }
    
    func presentMoreDetails(cell: RequestSummaryCell) {
        presentDetailView(for: cell)
    }
    
    @IBAction func unwindToLandingVC(_ segue: UIStoryboardSegue) {
        refreshData()
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
