//
//  CardDetailVC.swift
//  ANSWR - Code & Nibfile imported From Kasei
//
//  Created by Eugene L. on 24/01/21.
//

import UIKit

class CardDetailVC: UIViewController {

    @IBOutlet weak var cardTitle: UILabel!
    @IBOutlet weak var dismissBtn: UIButton!
    @IBOutlet weak var cardTableView: UITableView!

    @IBAction func clickedDismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
