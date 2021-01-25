//
//  PaddingLabel.swift
//  ANSWR - Code imported From Kasei
//
//  Modified from Tai Le's answer, https://stackoverflow.com/questions/27459746/adding-space-padding-to-a-uilabel
//

import UIKit

class PaddingLabel: UILabel {
    @IBInspectable var topInset: CGFloat = 5.0
    @IBInspectable var bottomInset: CGFloat = 5.0
    @IBInspectable var leftInset: CGFloat = 7.0
    @IBInspectable var rightInset: CGFloat = 7.0

    override func drawText(in rect: CGRect) {
        if self.text != "" {
            let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
            super.drawText(in: rect.inset(by: insets))
        } else {
            super.drawText(in: rect)
        }
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        if self.text != "" {
            return CGSize(width: size.width + leftInset + rightInset,
                          height: size.height + topInset + bottomInset)
        } else {
            return CGSize(width: size.width, height: size.height)
        }
    }

    override var bounds: CGRect {
        didSet {
            // ensures this works within stack views if multi-line
            preferredMaxLayoutWidth = bounds.width - (leftInset + rightInset)
        }
    }
}
