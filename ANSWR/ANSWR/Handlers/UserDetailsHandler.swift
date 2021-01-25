//
//  UserDetailsHandler.swift
//  ANSWR - Code imported From Kasei
//
//  Created by Eugene L. on 24/01/21.
//

import Foundation
import FirebaseDatabase

struct ProfileDetails {
    var name: String
    var email: String
    var zones: [String]
}

struct UserDetailsHandler {
    
    static func retrieveProfileDetails(onComplete: @escaping (ProfileDetails?) -> ()) {
        
        let DBRef = Database.database().reference()
        
        guard let uid = FirAuthHandler.firAuth.currentUser?.uid else {
            onComplete(nil)
            return
        }
        
        DBRef.child("volunteer/\(uid)").observeSingleEvent(of: .value) { (snapshot) in
            
            guard let name = snapshot.childSnapshot(forPath: "Name").value as? String else {
                onComplete(nil)
                return
            }
            
            guard let email = snapshot.childSnapshot(forPath: "Email").value as? String else {
                onComplete(nil)
                return
            }
            
            guard let zonesString = snapshot.childSnapshot(forPath: "AssignedZones").value as? String else {
                onComplete(nil)
                return
            }
            
            let zones = zonesString.components(separatedBy: ",")
            
            onComplete(ProfileDetails(name: name, email: email, zones: zones))
        }
    }
}
