//
//  Request.swift
//  ANSWR - Code imported From Kasei
//
//  Created by Eugene L. on 24/01/21.
//

import Foundation
import FirebaseDatabase

struct Request: Codable {
    var id: String?
    var dateCreated: Date?
    var senderID: String
    var status: String?
    var delSlotStart: Date?
    var items: Array<RequestItem>
    var isNew: Bool?
    
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
}

//TODO: Change function to update request status
//func postRequest(DBRef: DatabaseReference, req: Request, onComplete: @escaping (Bool) -> ()) {
//    let authHandler = FirAuthHandler.self
//    guard let uid = authHandler.firAuth.currentUser?.uid else {
//        return
//    }
//
//    var items = [String : Int]()
//    for itm in req.items {
//        items[itm.id] = itm.qty
//    }
//
//    let now = Calendar.current.dateComponents(in: .current, from: Date())
//    let tmr = DateComponents(year: now.year, month: now.month, day: now.day, hour: 8)
//    let defaultSlot = Calendar.current.date(from: tmr)!.timeIntervalSince1970
//    let delSlotStart = Int64((req.delSlotStart?.timeIntervalSince1970 ?? defaultSlot * 1000).rounded()) * 1000
//
//    let reqDict = ["dateCreated": Date().timeIntervalSince1970, "content": items, "delSlotStart" : delSlotStart, "senderID" : req.senderID, "status" : req.status ?? ""] as [String : Any]
//
//    UserDetailsHandler.retrieveSubzone(DBRef: DBRef) { (zoneid, success) in
//        if success {
//            let reqID = DBRef.child("requests/\(zoneid)").childByAutoId()
//            reqID.setValue(reqDict) { (err, _) in
//                guard err == nil else {
//                    onComplete(false)
//                    return
//                }
//
//                DBRef.child("userRequests/\(uid)/\(zoneid)").childByAutoId().setValue(reqID.key) { (err2, _) in
//                    guard err2 == nil else {
//                        onComplete(false)
//                        return
//                    }
//
//                    updateCounters(for: req.items, with: DBRef, in: zoneid)
//                    onComplete(true)
//                }
//            }
//        } else {
//            onComplete(false)
//        }
//    }
//}

func updateCounters(for items: [RequestItem], with DBRef: DatabaseReference, in zoneid: String) {
    for item in items {
        DBRef.child("items/\(item.id)/stock").runTransactionBlock { (data) -> TransactionResult in
            var stock = data.value as? Int ?? 0
            stock -= item.qty
            data.value = stock
            return TransactionResult.success(withValue: data)
        }
        
        DBRef.child("requestCounter/\(zoneid)/\(item.id)").runTransactionBlock { (data) -> TransactionResult in
            var itemCounter = data.value as? Int ?? 0
            itemCounter += item.qty
            
            data.value = itemCounter
            return TransactionResult.success(withValue: data)
        }
        
        DBRef.child("items/\(item.id)/requested").runTransactionBlock { (data) -> TransactionResult in
            var requestedCounter = data.value as? Int ?? 0
            requestedCounter += item.qty
            data.value = requestedCounter
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
            onComplete(Request(id: id, dateCreated: dateCreated, senderID: senderID, status: status, delSlotStart: delSlotStartDate, items: items))
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
