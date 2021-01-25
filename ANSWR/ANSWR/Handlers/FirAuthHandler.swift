//
//  FirAuthHandler.swift
//  ANSWR - Code imported From Kasei
//
//  Created by Eugene L. on 24/01/21.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

enum FirAuthHandlerResult {
    case invalidEmail
    case missingEmail
    case wrongDetails
    case wrongRole
    case other
    case success
}

struct FirAuthHandler {
    
    static var dbRef = Database.database().reference()
    static var firAuth = Auth.auth()
    
    static func loggedIn() -> Bool { return Auth.auth().currentUser != nil }
    
    static func presentSignin(over baseVC: UIViewController) {
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()
        guard let loginVC = vc else { return }
        loginVC.modalPresentationStyle = .fullScreen
        baseVC.present(loginVC, animated: true, completion: nil)
    }
    
    static func signout() {
        do {
            try firAuth.signOut()
        } catch let error as NSError {
            print(error)
        }
    }
    
    static func signin(email: String, pw: String, result: @escaping (FirAuthHandlerResult) -> ()) {
        firAuth.signIn(withEmail: email, password: pw) { (user, err) in
            
            // check if errors exist
            
            guard err == nil else {
                if let nsErr = err as NSError? {
                    if let authErr = AuthErrorCode(rawValue: nsErr.code) {
                        //handle errors
                        result(handleAuthErrors(authErr: authErr))
                    }
                }
                return
            }
            
            // if no errors, continue
            
            guard let uid = firAuth.currentUser?.uid else {
                return
            }
            
            // check authrole
            dbRef.child("authroles/\(uid)").observeSingleEvent(of: .value) { (snapshot) in
                guard let role = snapshot.value as? String else {
                    result(.other)
                    return
                }
                if role == "volunteer" {
                    result(.success)
                } else {
                    signout()
                    result(.wrongRole)
                }
            }
        }
    }
    
    static func handleAuthErrors(authErr: AuthErrorCode) -> FirAuthHandlerResult {
        switch authErr {
        case .invalidEmail:
            return .invalidEmail
        case .missingEmail:
            return .missingEmail
        case .wrongPassword, .userNotFound:
            return .wrongDetails
        default:
            return .other
        }
    }
}

