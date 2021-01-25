//
//  CDHandler.swift
//  ANSWR - Code imported From Kasei
//
//  Created by Eugene L. on 24/01/21.
//

import UIKit
import CoreData

struct CDHandler {
    
    static func saveZoneRequest(zoneid: String, requests: Array<Request>) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let zonreqEntity = NSEntityDescription.entity(forEntityName: "CDZoneRequests", in: context)!
        let reqEntity = NSEntityDescription.entity(forEntityName: "CDRequest", in: context)!
        let reqitemEntity = NSEntityDescription.entity(forEntityName: "CDRequestItem", in: context)!
        
        // create zone requests
        let cdzonerequests = CDZoneRequests(entity: zonreqEntity, insertInto: context)
        cdzonerequests.setValue(zoneid, forKey: "zoneid")
        
        // add requests to zone requests
        for req in requests {
            let cdrequest = CDRequest(entity: reqEntity, insertInto: context)
            cdrequest.setValue(req.id, forKey: "id")
            cdrequest.setValue(req.dateCreated, forKey: "dateCreated")
            cdrequest.setValue(req.senderID, forKey: "senderID")
            cdrequest.setValue(req.status, forKey: "status")
            cdrequest.setValue(req.delSlotStart, forKey: "delSlotStart")
            cdrequest.setValue(true, forKey: "isNew")
            
            // add items to request
            for item in req.items {
                let cditem = CDRequestItem(entity: reqitemEntity, insertInto: context)
                cditem.setValue(item.id, forKey: "id")
                cditem.setValue(item.name, forKey: "name")
                cditem.setValue(item.icon, forKey: "icon")
                cditem.setValue(item.qty, forKey: "qty")
                cditem.setValue(item.bgCol, forKey: "bgCol")
                cditem.setValue(item.qtyLimit, forKey: "qtyLimit")
                cditem.setValue(item.qtyRemaining, forKey: "qtyRemaining")
                
                cdrequest.addToItems(cditem)
            }
            
            cdzonerequests.addToRequests(cdrequest)
        }
        
        // save changes made
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save. \(error) \(error.userInfo)")
        }
    }
    
    static func deleteZoneRequest(with id: String, from zoneid: String) {
        var cdzonereqs = [CDZoneRequests]()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<CDZoneRequests>(entityName: "CDZoneRequests")
        request.predicate = NSPredicate(format: "zoneid == %s", argumentArray: [zoneid])
        
        do {
            cdzonereqs = try context.fetch(request)
            if let cdzr = cdzonereqs.first {
                let requests = cdzr.requests?.allObjects as! [CDRequest]
                for req in requests {
                    if req.id == id {
                        context.delete(req)
                    }
                }
            }
            
            try context.save()
        } catch let error as NSError {
            print("Could not delete. \(error) \(error.userInfo)")
        }
    }
    
    static func loadAllZoneRequests() -> [ZoneRequests] {
        var zoneRequests = [ZoneRequests]()
        var cdzoneRequests = [CDZoneRequests]()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<CDZoneRequests>(entityName: "CDZoneRequests")
        
        do {
            cdzoneRequests = try context.fetch(request)
        }  catch let error as NSError {
            print("Could not fetch. \(error) \(error.userInfo)")
            return zoneRequests
        }
        
        // if fetch is successful, convert cd class into regular class
        for cdzr in cdzoneRequests {
            
            let zonereq = ZoneRequests(zoneid: cdzr.zoneid!, requests: [])
            var cdrequests = cdzr.requests?.allObjects as! [CDRequest]
            cdrequests.sort{$0.dateCreated! < $1.dateCreated!}
            
            for cdr in cdrequests {
                var req = Request(id: cdr.id, dateCreated: cdr.dateCreated, senderID: cdr.senderID!, status: cdr.status, delSlotStart: cdr.delSlotStart, items: [])
                req.isNew = cdr.isNew
                
                var cditems = cdr.items?.allObjects as! [CDRequestItem]
                cditems.sort{$0.name! < $1.name!}

                for cdi in cditems {
                    let itm = RequestItem(id: cdi.id!, name: cdi.name!, icon: cdi.icon!, qty: Int(cdi.qty), bgCol: cdi.bgCol!)
                    req.items.append(itm)
                }
                
                zonereq.requests.append(req)
            }
            
            zoneRequests.append(zonereq)
        }
        
        return zoneRequests
    }
    
//TODO: UPDATE THESE LATER
    
    static func markRequestAsOld(id: String) {
        var cdrequests = [CDRequest]()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<CDRequest>(entityName: "CDRequest")
        request.predicate = NSPredicate(format: "id == %s", argumentArray: [id])
        
        do {
            cdrequests = try context.fetch(request)
            if cdrequests.first != nil {
                cdrequests.first!.setValue(false, forKey: "isNew")
            }
            
            try context.save()
        } catch let error as NSError {
            print("Could not update. \(error) \(error.userInfo)")
        }
    }
    
    static func updateSavedRequests(newZoneRequests: [ZoneRequests]) {
        var oldZoneRequests = loadAllZoneRequests()
        var newZoneRequests = newZoneRequests
        
//        // leave matching requests alone
//        while oldZoneRequests.count > 0 {
//
//            var hasMatch = false
//            let oldzonereqFirst = oldZoneRequests.first!
//
//            for i in 0..<newZoneRequests.count {
//                for j in 0..<newZoneRequests[i].requests.count {
//                    let oldreq = oldzonereqFirst.requests.first!
//                    let newreq = newZoneRequests[i].requests[j]
//                    if oldreq.id == newreq.id && oldreq.status == newreq.status {
//                        if oldreq.isNew ?? false {
//                            markRequestAsOld(id: oldreq.id!)
//                        }
//                        newZoneRequests[i].requests.remove(at: j)
//                        oldzonereqFirst.requests.removeFirst()
//                        hasMatch = true
//                        break
//                    }
//                }
//            }
//
//            // delete old requests
//            if !hasMatch {
//                deleteZoneRequest(with: oldzonereqFirst.requests.first!.id!, from: oldzonereqFirst.zoneid)
//                oldzonereqFirst.requests.removeFirst()
//            }
//        }
//
//        // save new requests
//        for zonereqs in newZoneRequests {
//            saveZoneRequest(zoneid: zonereqs.zoneid, requests: zonereqs.requests)
//        }
    }
    
}
