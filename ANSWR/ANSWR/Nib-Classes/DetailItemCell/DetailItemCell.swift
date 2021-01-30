//
//  DetailItemCell.swift
//  ANSWR
//
//  Created by Eugene L. on 29/1/21.
//

import UIKit

class DetailItemCell: UITableViewCell {

    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var qtyLabel: UILabel!
    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var strikethrough: UIView!
    
    var delegate: ChecklistProtocol?
    var itemID: String?
    
    static func register(for tableView: UITableView) {
        tableView.register(UINib(nibName: "DetailItemCell", bundle: nil), forCellReuseIdentifier: "detailItemCell")
    }
    
    static func buildInstance(for tableView: UITableView, checked: Bool) -> DetailItemCell? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "detailItemCell") as? DetailItemCell else {
            return nil
        }
        cell.checkBtn.isSelected = checked
        cell.strikethrough.isHidden = !checked
        
        return cell
    }

    @IBAction func toggleChecked(_ sender: Any) {
        checkBtn.isSelected = !checkBtn.isSelected
        strikethrough.isHidden = !strikethrough.isHidden
        delegate!.toggledItemCheck(itemID: itemID!)
    }
    
}
