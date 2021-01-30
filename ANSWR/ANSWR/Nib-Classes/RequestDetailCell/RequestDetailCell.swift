//
//  RequestDetailCell.swift
//  ANSWR
//
//  Created by Eugene L. on 28/1/21.
//

import UIKit

class RequestDetailCell: ElevatedTableViewCell, UITableViewDelegate, UITableViewDataSource, ChecklistProtocol {
    
    @IBOutlet weak var isNewIndicator: UIView!
    @IBOutlet weak var detailContainer: UIView!
    @IBOutlet weak var requestIDLabel: UILabel!
    @IBOutlet weak var timeslotLabel: UILabel!
    @IBOutlet weak var addressField: UITextViewFixed!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var itemTableView: UITableView!
    @IBOutlet weak var completionBtn: UIButton!
    
    // data store
    var zoneid: String?
    var request: Request?
    var delegate: TasksheetProtocol?
    
    override func awakeFromNib() {
        containerView = detailContainer
        
        super.awakeFromNib()
        detailContainer.layer.cornerRadius = 10
        itemTableView.delegate = self;
        itemTableView.dataSource = self;
        itemTableView.automaticallyAdjustsScrollIndicatorInsets = false
        DetailItemCell.register(for: itemTableView);
    }
    
    func setup() {
        separatorInset = UIEdgeInsets.zero
        preservesSuperviewLayoutMargins = false
        layoutMargins = UIEdgeInsets.zero
        timeslotLabel.textColor = UIColor.label
        completionBtn.alpha = 0.3;
        completionBtn.isEnabled = false;
    }
    
    static func register(for tableView: UITableView) {
        tableView.register(UINib(nibName: "RequestDetailCell", bundle: nil), forCellReuseIdentifier: "requestDetailCell")
    }
    
    static func buildInstance(for tableView: UITableView, request: Request) -> RequestDetailCell? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "requestDetailCell") as? RequestDetailCell else {
            return nil
        }
        cell.setup()
        
        cell.isNewIndicator.isHidden = !request.isNew!
        cell.requestIDLabel.text = request.id
        cell.timeslotLabel.text = request.delSlotString()
        
        if request.delSlotStart! < Date() {
            cell.timeslotLabel.textColor = UIColor(named: "Error")
            cell.timeslotLabel.text! += "  (Late)"
        }
        
        cell.addressField.text = request.elderlyAddressString
        cell.nameLabel.text = "Recepient: \(request.elderlyName!)"
        cell.request = request
        cell.itemTableView.reloadData()
        cell.updateCompletionBtn()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return request!.items.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = request!.items[indexPath.row]
        if let cell = DetailItemCell.buildInstance(for: itemTableView, checked: item.checked!) {
            cell.itemLabel.text = "- \(item.name)"
            cell.qtyLabel.text = "x\(item.qty)"
            cell.itemID = item.id
            cell.delegate = self
            
            return cell;
        } else {
            return UITableViewCell();
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func updateCompletionBtn() {
        var allChecked = true
        for item in request!.items {
            if !item.checked! {
                allChecked = false
                break
            }
        }
        if allChecked {
            completionBtn.isEnabled = true
            completionBtn.alpha = 1
        } else {
            completionBtn.isEnabled = false
            completionBtn.alpha = 0.3
        }
    }
    
    func toggledItemCheck(itemID: String) {
        if let item = request!.items.first(where: {$0.id == itemID}) {
            item.checked = !item.checked!
            CDHandler.markChecked(reqID: request!.id!, itemID: itemID, checked: item.checked!)
        }
        updateCompletionBtn()
    }

    @IBAction func completionBtnClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Complete Request?", message: "Please confirm that the request has been fulfilled before proceeding with this action.", preferredStyle: .alert)
        alert.addAction(.init(title: "Confirm", style: .destructive, handler: { (_) in
            self.delegate!.completeRequest(req: self.request!, zoneid: self.zoneid!)
        }))
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        delegate!.presentAlert(alert: alert)
    }
    
}

protocol ChecklistProtocol {
    func toggledItemCheck(itemID: String)
}
