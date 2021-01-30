//
//  UITextViewFixed.swift
//  ANSWR
//
//  Referenced from https://stackoverflow.com/questions/746670/how-to-lose-margin-padding-in-uitextview
//  Created by https://stackoverflow.com/users/294884/fattie
//  with input from https://stackoverflow.com/users/1340499/fab1n
//

import UIKit

@IBDesignable class UITextViewFixed: UITextView {
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    func setup() {
        translatesAutoresizingMaskIntoConstraints = true
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
        translatesAutoresizingMaskIntoConstraints = false
    }
}
