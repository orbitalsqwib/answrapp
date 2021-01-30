//
//  Request.swift
//  ANSWR - Code imported From Kasei
//
//  Created by Eugene L. on 24/01/21.
//

import Foundation
import FirebaseDatabase

struct Request: Codable, Equatable {
    
    var id: String?
    var dateCreated: Date?
    var senderID: String
    var status: String?
    var delSlotStart: Date?
    var items: Array<RequestItem>
    var isNew: Bool?
    var elderlyName: String?
    var elderlyAddressString: String?
    
    init(id: String?, dateCreated: Date?, senderID: String, status: String?, delSlotStart: Date?, items: Array<RequestItem>) {
        self.id = id
        self.dateCreated = dateCreated
        self.senderID = senderID
        self.status = status
        self.delSlotStart = delSlotStart
        self.items = items
    }
    
    func delSlotString() -> String? {
        // format date
        if let slotStart = delSlotStart {
            let slotEnd = slotStart.addingTimeInterval(.init(60*60*2)) // +2h
            let startFormatter = DateFormatter()
            
            let localisedFormatStart = DateFormatter.dateFormat(fromTemplate: "dd MMM yyyy, ha", options: 0, locale: Locale.current)
            let localisedFormatEnd = DateFormatter.dateFormat(fromTemplate: "ha", options: 0, locale: Locale.current)
            
            startFormatter.dateFormat = localisedFormatStart
            let endFormatter = DateFormatter()
            endFormatter.dateFormat = localisedFormatEnd
            
            return startFormatter.string(from: slotStart) + " - " + endFormatter.string(from: slotEnd)
        }
        return nil
    }
    
    static func == (lhs: Request, rhs: Request) -> Bool {
        let idCheck = lhs.id == rhs.id
        let statusCheck = lhs.status == rhs.status
        let delSlotCheck = lhs.status == rhs.status
        
        var itemsCheck = true
        for item in lhs.items {
            if !rhs.items.contains(item) {
                itemsCheck = false
                break
            }
        }
        
        let nameCheck = lhs.elderlyName == rhs.elderlyName
        let addrCheck = lhs.elderlyAddressString == rhs.elderlyAddressString
        return idCheck && statusCheck && delSlotCheck && nameCheck && addrCheck && itemsCheck
    }
}

func markRequestAsComplete(for request: Request, in zoneID: String, onComplete: @escaping ()->()) {
    let DBRef = Database.database().reference()
    let uid = FirAuthHandler.firAuth.currentUser!.uid
    
    updateCounters(for: request.items, with: DBRef, in: zoneID)
    DBRef.child("userRequests/\(request.senderID)/\(zoneID)/").observeSingleEvent(of: .value) { (snapshot) in
        for child in snapshot.children {
            let childSnap = child as! DataSnapshot
            let key = childSnap.key
            if (snapshot.childSnapshot(forPath: key).value as! String) == request.id {
                DBRef.child("userRequests/\(request.senderID)/\(zoneID)/\(key)").setValue(nil)
                break
            }
        }
    }
    DBRef.child("volunteer/\(uid)/CompletedRequests").runTransactionBlock { (data) -> TransactionResult in
        var reqCompletedCounter = data.value as? Int ?? 0
        reqCompletedCounter += 1
        
        data.value = reqCompletedCounter
        return TransactionResult.success(withValue: data)
    }
    DBRef.child("requests/\(zoneID)/\(request.id!)").setValue(nil) { (err, ref) in
        onComplete()
    }
}

func updateCounters(for items: [RequestItem], with DBRef: DatabaseReference, in zoneid: String) {
    for item in items {
        DBRef.child("requestCounter/\(zoneid)/\(item.id)").runTransactionBlock { (data) -> TransactionResult in
            var itemCounter = data.value as? Int ?? 0
            itemCounter -= item.qty
            
            data.value = itemCounter
            if itemCounter <= 0 {
                data.value = nil
            }
            return TransactionResult.success(withValue: data)
        }
        
        DBRef.child("items/\(item.id)/requested").runTransactionBlock { (data) -> TransactionResult in
            var requestedCounter = data.value as? Int ?? 0
            requestedCounter -= item.qty
            data.value = requestedCounter
            if requestedCounter <= 0 {
                data.value = nil
            }
            return TransactionResult.success(withValue: data)
        }
    }
}

func getRequest(DBRef: DatabaseReference, forZoneID zoneID: String, forID id: String, onComplete: @escaping (Request?) -> ()) {
    DBRef.child("requests/\(zoneID)/\(id)").observeSingleEvent(of: .value) { (snapshot) in
        let id = snapshot.key
        
        guard let dateCreatedSeconds = snapshot.childSnapshot(forPath: "dateCreated").value as? Double else {
            onComplete(nil)
            return
        }
        
        let dateCreated = Date(timeIntervalSince1970: dateCreatedSeconds)
        
        guard let senderID = snapshot.childSnapshot(forPath: "senderID").value as? String else {
            onComplete(nil)
            return
        }
        
        guard let status = snapshot.childSnapshot(forPath: "status").value as? String else {
            onComplete(nil)
            return
        }
        
        guard let delSlotStart = snapshot.childSnapshot(forPath: "delSlotStart").value as? Int else {
            onComplete(nil)
            return
        }
        
        let delSlotStartDate = Date(timeIntervalSince1970: TimeInterval(delSlotStart) / 1000 )
        
        let contentSnap = snapshot.childSnapshot(forPath: "content")
        getAllItems(DBRef: DBRef, forContentSnapshot: contentSnap) { (items) in
            
            UserDetailsHandler.retrieveElderlyDetails(DBRef: DBRef, for: senderID) { (details) in
                var req = Request(id: id, dateCreated: dateCreated, senderID: senderID, status: status, delSlotStart: delSlotStartDate, items: items)
                req.elderlyName = details?.name
                req.elderlyAddressString = details?.address
                
                onComplete(req)
            }
        }
    }
}

func getAllItems(DBRef: DatabaseReference, forContentSnapshot snap: DataSnapshot, onComplete: @escaping ([RequestItem]) -> ()) {
    var items = [RequestItem]()
    var counter = snap.childrenCount
    for child in snap.children {
        let childSnap = child as! DataSnapshot
        let itemID = childSnap.key
        getRequestItem(DBRef: DBRef, forID: itemID) { (item) in
            if let i = item {
                i.qty = childSnap.value as! Int
                items.append(i)
            }
            
            counter -= 1
            if counter == 0 {
                onComplete(items)
            }
        }
    }
}
