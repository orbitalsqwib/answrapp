//
//  ProfileDetailsCell.swift
//  ANSWR - Code imported From Kasei
//
//  Created by Eugene L. on 24/01/21.
//

import UIKit
class ProfileDetailsCell: ElevatedTableViewCell {
    
    @IBOutlet weak var detailContainer: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contactNoLabel: UILabel!
    @IBOutlet weak var zoneLabel: UILabel!
    
    override func awakeFromNib() {
        containerView = detailContainer
        
        super.awakeFromNib()
        detailContainer.layer.cornerRadius = 10
    }
    
    static func register(for tableView: UITableView) {
        tableView.register(UINib(nibName: "ProfileDetailsCell", bundle: nil), forCellReuseIdentifier: "profileDetailsCell")
    }
    
    static func buildInstance(for tableView: UITableView) -> ProfileDetailsCell? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "profileDetailsCell") as? ProfileDetailsCell else {
            return nil
        }
        
        return cell
    }
}
