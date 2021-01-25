//
//  ZoneRequests.swift
//  ANSWR
//
//  Created by Eugene L. on 24/1/21.
//

import Foundation

class ZoneRequests {
    var zoneid: String
    var requests: Array<Request>
    
    init(zoneid: String, requests: Array<Request>) {
        self.zoneid = zoneid
        self.requests = requests
    }
}
