//
//  ButtonCell.swift
//  ANSWR - Code imported From Kasei
//
//  Created by Eugene L. on 24/01/21.
//

import UIKit

class ButtonCell: UITableViewCell {
    
    @IBOutlet weak var btn: UIButton!
    
    var delegate: ButtonCellProtocol? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        btn.layer.cornerRadius = 10
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        delegate = nil
    }
    
    @IBAction func btnClicked(_ sender: Any) {
        if delegate != nil {
            delegate!.buttonClicked(reuseId: self.reuseIdentifier ?? "")
        }
    }
    
    static func register(withReuseId id: String, for tableView: UITableView) {
        tableView.register(UINib(nibName: "ButtonCell", bundle: nil), forCellReuseIdentifier: id)
    }
    
    static func buildInstance(withReuseId id: String, for tableView: UITableView, delegate: ButtonCellProtocol?) -> ButtonCell? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: id) as? ButtonCell else {
            return nil
        }
        
        cell.delegate = delegate
        return cell
    }
}

protocol ButtonCellProtocol {
    func buttonClicked(reuseId: String)
}
