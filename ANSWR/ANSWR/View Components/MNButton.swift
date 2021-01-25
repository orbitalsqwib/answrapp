//
//  MNButton.swift
//  ANSWR - Code imported From Kasei
//
//  Created by Eugene L. on 24/01/21.
//

import UIKit

class MNButton: UIButton {
    
    var originalBgCol: UIColor?
    var originalTxtCol: UIColor?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.originalBgCol = self.backgroundColor
        self.originalTxtCol = self.titleColor(for: .normal)
    }

    override var isEnabled: Bool {
        didSet {
            if (self.isEnabled == false) {
                self.backgroundColor = UIColor(named: "Button Disabled")
            } else {
                self.backgroundColor = originalBgCol
            }
        }
    }
    
    func coloriseWithAccent(enabled: Bool) {
        if enabled {
            self.setTitleColor(UIColor(named: "Accent Static"), for: .normal)
        } else {
            self.setTitleColor(originalTxtCol, for: .normal)
        }
    }
}
