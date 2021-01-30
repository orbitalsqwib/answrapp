//
//  ZoneRequests.swift
//  ANSWR
//
//  Created by Eugene L. on 24/1/21.
//

import Foundation
import FirebaseDatabase

class ZoneRequests {
    var zoneid: String
    var requests: Array<Request>
    
    init(zoneid: String, requests: Array<Request>) {
        self.zoneid = zoneid
        self.requests = requests
    }
}

func getZoneRequests(DBRef: DatabaseReference, for zoneid: String, onComplete: @escaping (ZoneRequests?)->()) {
    DBRef.child("requests/\(zoneid)").observeSingleEvent(of: .value) { (snapshot) in
        guard snapshot.exists() else {
            onComplete(nil)
            return
        }
        
        let zr = ZoneRequests(zoneid: zoneid, requests: [Request]())
        var reqCounter = snapshot.childrenCount
        for child in snapshot.children {
            let childSnap = child as! DataSnapshot
            let reqID = childSnap.key
            getRequest(DBRef: DBRef, forZoneID: zoneid, forID: reqID) { (req) in
                if let r = req {
                    zr.requests.append(r)
                }
                reqCounter -= 1
                if reqCounter == 0 {
                    onComplete(zr)
                }
            }
        }
    }
}
