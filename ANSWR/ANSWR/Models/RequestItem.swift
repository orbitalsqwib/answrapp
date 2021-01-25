//
//  RequestItem.swift
//  ANSWR - Code imported From Kasei
//
//  Created by Eugene L. on 24/01/21.
//

import Foundation
import FirebaseDatabase

class RequestItem: Codable {
    var id: String
    var name: String
    var icon: String
    var qty: Int
    var qtyLimit: Int?
    var qtyRemaining: Int?
    var bgCol: String
    
    init(id: String, name: String, icon: String, qty: Int, bgCol: String) {
        self.id = id
        self.name = name
        self.icon = icon
        self.qty = qty
        self.bgCol = bgCol
    }
}

func getRequestItem(DBRef: DatabaseReference, forID id: String, onComplete: @escaping (RequestItem?) -> ()) {
    DBRef.child("items/\(id)").observeSingleEvent(of: .value) { (snapshot) in
        
        var path = "name"
        
        if Locale.current.languageCode == "zh" {
            path += "_zh"
        }
        
        var name = snapshot.childSnapshot(forPath: path).value as? String
        if name == nil {
            name = snapshot.childSnapshot(forPath: "name").value as? String
        }
        
        guard name != nil else {
            onComplete(nil)
            return
        }
        
        guard let icon = snapshot.childSnapshot(forPath: "icon").value as? String else {
            onComplete(nil)
            return
        }
        
        guard let bgCol = snapshot.childSnapshot(forPath: "bgCol").value as? String else {
            onComplete(nil)
            return
        }
        
        let reqItem = RequestItem(id: id, name: name!, icon: icon, qty: 0, bgCol: bgCol)
        
        if let limit = snapshot.childSnapshot(forPath: "limit").value as? Int {
            reqItem.qtyLimit = limit
        }
        
        if let remaining = snapshot.childSnapshot(forPath: "remaining").value as? Int {
            reqItem.qtyRemaining = remaining
        }
        
        onComplete(reqItem)
    }
}
