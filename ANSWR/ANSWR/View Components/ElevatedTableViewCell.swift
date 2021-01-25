//
//  ElevatedTableViewCell.swift
//  ANSWR - Code imported From Kasei
//
//  Created by Eugene L. on 24/01/21.
//

import UIKit

class ElevatedTableViewCell: UITableViewCell {
    
    var containerView: UIView? = nil
    let enabledShadowOpacity: Float = 0.5

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if let container = containerView {
            container.setShadow(
                col: UIColor.lightGray.cgColor,
                opacity: enabledShadowOpacity,
                offset: .zero,
                rad: 5)
            traitCollectionDidChange(self.traitCollection)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if let container = containerView {
            if traitCollection.userInterfaceStyle == .dark {
                container.layer.shadowOpacity = 0
            } else {
                container.layer.shadowOpacity = enabledShadowOpacity
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
