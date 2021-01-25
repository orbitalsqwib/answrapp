//
//  MoreInfoViewController.swift
//  ANSWR - Code & Nibfile imported From Kasei
//
//  Created by Eugene L. on 24/01/21.
//

import UIKit

class MoreInfoViewController: UIViewController {
    
    // Change this URL to a sample about us page.
    let infoURL = "https://www.google.com"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let fontAttr = UIFont(name: "Avenir Next Bold", size: 40.0) else { return }
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: fontAttr]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let fontAttr = UIFont(name: "Avenir Next Bold", size: 50.0) else { return }
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: fontAttr]
    }
    
    @IBAction func clickedLearnBtn(_ sender: Any) {
        if let url = URL(string: infoURL) {
            UIApplication.shared.open(url)
        }
    }

}
