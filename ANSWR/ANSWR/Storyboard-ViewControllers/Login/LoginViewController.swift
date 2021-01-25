//
//  LoginViewController.swift
//  ANSWR - Code & Nibfile imported From Kasei
//
//  Created by Eugene L. on 24/01/21.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController, UITextFieldDelegate {

    //MARK: View Objects
    
    @IBOutlet weak var emailContainer: UIView!
    @IBOutlet weak var emailFld: UITextField!
    @IBOutlet weak var emailLine: UIView!
    
    @IBOutlet weak var pwContainer: UIView!
    @IBOutlet weak var pwFld: UITextField!
    @IBOutlet weak var pwLine: UIView!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var signInBtn: MNButton!
    @IBOutlet weak var aboutBtn: UIButton!
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    
    //MARK: Variables
    
    var emailField: LoginField?
    var pwField: LoginField?
    let authHandler = FirAuthHandler.self
    
    //MARK: Delegate methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authHandler.signout()
        
        emailFld.delegate = self
        pwFld.delegate = self
        
        emailField = LoginField(container: emailContainer, textfield: emailFld, accentLine: emailLine)
        pwField = LoginField(container: pwContainer, textfield: pwFld, accentLine: pwLine)
        
        // Start view with focus on emailLine
        emailFld.becomeFirstResponder()

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        gotoNextFieldFor(textField: textField)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateFieldsOnEdit(textField)
        if let lf = getLoginFieldFor(textField: textField) {
            lf.accentLine.backgroundColor = UIColor(named: "Accent Static")
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let lf = getLoginFieldFor(textField: textField) {
            lf.accentLine.backgroundColor = UIColor(named: "Textfield Accent")
        }
    }
    
    @IBAction func clickedSignIn(_ sender: Any) {
        signInBtn.coloriseWithAccent(enabled: false)
        signIn()
    }
    
    @IBAction func tapOutOfKeyboard(_ sender: Any) {
        signInBtn.coloriseWithAccent(enabled: false)
        self.view.endEditing(true)
    }
    
    //MARK: Class Functions
    
    func gotoNextFieldFor(textField: UITextField) {
        switch textField {
        case emailFld:
            pwFld.becomeFirstResponder()
        default:
            pwFld.resignFirstResponder()
            signInBtn.coloriseWithAccent(enabled: true)
        }
    }
    
    func getLoginFieldFor(textField: UITextField) -> LoginField? {
        switch textField {
        case emailField?.textfield:
            return emailField
        case pwField?.textfield:
            return pwField
        default:
            return nil
        }
    }
    
    func updateFieldsOnEdit(_ textField: UITextField) {
        if let lf = getLoginFieldFor(textField: textField) {
            if(lf.hasError) {
                dismissErrors()
            }
        }
        
        // Update Sign In Btn
        signInBtn.coloriseWithAccent(enabled: false)
        if !signInBtn.isEnabled {
            signInBtn.isEnabled = true
        }
    }
    
    func dismissErrors() {
        errorLabel.text = ""
        emailField?.dismissError()
        pwField?.dismissError()
    }
    
    func signIn() {
        let email = emailFld.text ?? ""
        let pw = pwFld.text ?? ""
        
        aboutBtn.isHidden = true
        loadIndicator.startAnimating()
        authHandler.signin(email: email, pw: pw) { (result) in
            self.aboutBtn.isHidden = false
            self.loadIndicator.stopAnimating()
            self.handleHandlerResult(result: result)
        }
    }
    
    func handleHandlerResult(result: FirAuthHandlerResult) {
        switch result {
        
        // errors
        case .invalidEmail:
            errorLabel.text = NSLocalizedString("This is not an email!", comment: "")
            emailField?.displayError()
        case .missingEmail:
            errorLabel.text = NSLocalizedString("No email found!", comment: "")
            emailField?.displayError()
        case .wrongDetails:
            errorLabel.text = NSLocalizedString("Wrong email or password!", comment: "")
            emailField?.displayError()
            pwField?.displayError()
        case .wrongRole:
            errorLabel.text = NSLocalizedString("Not a volunteer!", comment: "")
            emailField?.displayError()
            
        // success
        case .success:
            finishSignIn()
            
        // other
        default:
            errorLabel.text = NSLocalizedString("An unknown error occured. Please try again later.", comment: "")
            emailField?.displayError()
            pwField?.displayError()
        }
    }
    
    func finishSignIn() {
        self.navigationController?.dismiss(animated: true) { }
    }

}
