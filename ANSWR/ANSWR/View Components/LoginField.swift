//
//  Field.swift
//  ANSWR - Code imported From Kasei
//
//  Created by Eugene L. on 24/01/21.
//

import UIKit

struct LoginField {
    
    var container: UIView
    var textfield: UITextField
    var accentLine: UIView
    var hasError: Bool! = false;
    
    mutating func displayError() {
        textfield.text = ""
        accentLine.backgroundColor = UIColor(named: "Error")
        hasError = true
    }
    
    mutating func dismissError() {
        accentLine.backgroundColor = UIColor(named: "Textfield Accent")
        hasError = false
    }
}
