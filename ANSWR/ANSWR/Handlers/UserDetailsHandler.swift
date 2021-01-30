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
    var contactNo: String
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
            
            var contactNo = snapshot.childSnapshot(forPath: "Contact").value as? String ?? String(snapshot.childSnapshot(forPath: "Contact").value as? Int ?? -1)
            
            if contactNo == "-1" {
                contactNo = "Unavailable"
            }
            
            guard let zonesString = snapshot.childSnapshot(forPath: "AssignedZones").value as? String else {
                onComplete(nil)
                return
            }
            
            let zones = zonesString.components(separatedBy: ",")
            
            onComplete(ProfileDetails(name: name, contactNo: contactNo, zones: zones))
        }
    }
    
    static func retrieveZones(onComplete: @escaping ([String]?, String?)->()) {
        
        let DBRef = Database.database().reference()
        
        guard let uid = FirAuthHandler.firAuth.currentUser?.uid else {
            onComplete(nil, nil)
            return
        }
        
        DBRef.child("volunteer/\(uid)").observeSingleEvent(of: .value) { (snapshot) in
            
            guard let zonesString = snapshot.childSnapshot(forPath: "AssignedZones").value as? String else {
                onComplete(nil, uid)
                return
            }
            
            let zones = zonesString.components(separatedBy: ",")
            
            onComplete(zones, uid)
        }
    }
    
    static func retrieveElderlyDetails(DBRef: DatabaseReference, for uid: String, onComplete: @escaping (ElderlyDetails?)->()) {
        DBRef.child("elderly/\(uid)").observeSingleEvent(of: .value) { (snapshot) in
            guard let name = snapshot.childSnapshot(forPath: "Name").value as? String else {
                onComplete(nil)
                return
            }
            
            
            guard let address = snapshot.childSnapshot(forPath: "Address").value as? String else {
                onComplete(nil)
                return
            }
            
            var postalCode = snapshot.childSnapshot(forPath: "PostalCode").value as? String ?? String(snapshot.childSnapshot(forPath: "PostalCode").value as? Int ?? -1)
            
            if postalCode == "-1" {
                postalCode = "Unavailable"
            }
            
            onComplete(ElderlyDetails(address: "\(address), Singapore \(postalCode)", name: name))
        }
    }
}
