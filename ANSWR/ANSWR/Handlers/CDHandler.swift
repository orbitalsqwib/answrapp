//
//  CDHandler.swift
//  ANSWR - Code imported From Kasei
//
//  Created by Eugene L. on 24/01/21.
//

import UIKit
import CoreData

struct CDHandler {
    
    static func addRequestToZoneRequest(cdzr: CDZoneRequests, req: Request) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let reqEntity = NSEntityDescription.entity(forEntityName: "CDRequest", in: context)!
        let reqitemEntity = NSEntityDescription.entity(forEntityName: "CDRequestItem", in: context)!
        let cdrequest = CDRequest(entity: reqEntity, insertInto: context)
        cdrequest.setValue(req.id, forKey: "id")
        cdrequest.setValue(req.dateCreated, forKey: "dateCreated")
        cdrequest.setValue(req.senderID, forKey: "senderID")
        cdrequest.setValue(req.status, forKey: "status")
        cdrequest.setValue(req.delSlotStart, forKey: "delSlotStart")
        cdrequest.setValue(true, forKey: "isNew")
        cdrequest.setValue(req.elderlyName, forKeyPath: "elderlyName")
        cdrequest.setValue(req.elderlyAddressString, forKey: "elderlyAddressString")
        
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
            cditem.setValue(false, forKey: "checked")
            
            cdrequest.addToItems(cditem)
        }
        
        do {
            cdzr.addToRequests(cdrequest)
            try context.save()
        } catch let error as NSError {
            print("Could not update. \(error) \(error.userInfo)")
        }
    }
    
    static func saveZoneRequest(zonereq: ZoneRequests) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let zonreqEntity = NSEntityDescription.entity(forEntityName: "CDZoneRequests", in: context)!
        
        // create zone requests
        let cdzonerequests = CDZoneRequests(entity: zonreqEntity, insertInto: context)
        cdzonerequests.setValue(zonereq.zoneid, forKey: "zoneid")
        
        // add requests to zone requests
        for req in zonereq.requests {
            addRequestToZoneRequest(cdzr: cdzonerequests, req: req)
        }
        
        // save changes made
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save. \(error) \(error.userInfo)")
        }
    }
    
    static func addRequestToZoneUsingID(zoneID: String, req: Request) {
        var cdzonereqs = [CDZoneRequests]()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<CDZoneRequests>(entityName: "CDZoneRequests")
        request.predicate = NSPredicate(format: "zoneid == %s", argumentArray: [zoneID])
        
        do {
            cdzonereqs = try context.fetch(request)
            if let cdzr = cdzonereqs.first {
                addRequestToZoneRequest(cdzr: cdzr, req: req)
            }
            
            try context.save()
        } catch let error as NSError {
            print("Could not update. \(error) \(error.userInfo)")
        }
    }
    
    static func deleteZoneRequest(zoneID: String) {
        var cdzonereqs = [CDZoneRequests]()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<CDZoneRequests>(entityName: "CDZoneRequests")
        request.predicate = NSPredicate(format: "zoneid == %s", argumentArray: [zoneID])
        
        do {
            cdzonereqs = try context.fetch(request)
            if let cdzr = cdzonereqs.first {
                context.delete(cdzr)
            }
            
            try context.save()
        } catch let error as NSError {
            print("Could not delete. \(error) \(error.userInfo)")
        }
    }
    
    static func deleteRequest(id: String) {
        var cdrequests = [CDRequest]()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<CDRequest>(entityName: "CDRequest")
        request.predicate = NSPredicate(format: "id == %s", argumentArray: [id])
        
        do {
            cdrequests = try context.fetch(request)
            if let cdr = cdrequests.first {
                context.delete(cdr)
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
        let sortDescriptor = NSSortDescriptor(key: "zoneid", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
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
                var req = Request(id: cdr.id, dateCreated: cdr.dateCreated, senderID: cdr.senderID!, status: cdr.status, delSlotStart: cdr.delSlotStart!, items: [])
                req.isNew = cdr.isNew
                req.elderlyName = cdr.elderlyName
                req.elderlyAddressString = cdr.elderlyAddressString
                
                var cditems = cdr.items?.allObjects as! [CDRequestItem]
                cditems.sort{$0.name! < $1.name!}

                for cdi in cditems {
                    let itm = RequestItem(id: cdi.id!, name: cdi.name!, icon: cdi.icon!, qty: Int(cdi.qty), bgCol: cdi.bgCol!)
                    itm.checked = cdi.checked
                    req.items.append(itm)
                }
                
                zonereq.requests.append(req)
            }
            
            zoneRequests.append(zonereq)
        }
        
        return zoneRequests
    }
    
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
    
    static func markChecked(reqID: String, itemID: String, checked: Bool) {
        var cdrequests = [CDRequest]()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<CDRequest>(entityName: "CDRequest")
        request.predicate = NSPredicate(format: "id == %s", argumentArray: [reqID])
        
        do {
            cdrequests = try context.fetch(request)
            if cdrequests.first != nil {
                let cditems = cdrequests.first!.items!.allObjects as! [CDRequestItem]
                let item = cditems.first(where: {$0.id == itemID})
                item?.setValue(checked, forKey: "checked")
            }
            
            try context.save()
        } catch let error as NSError {
            print("Could not update. \(error) \(error.userInfo)")
        }
    }
    
    static func updateSavedRequests(newZoneRequests: [ZoneRequests]) {
        var oldZoneRequests = loadAllZoneRequests()
        var newZoneRequests = newZoneRequests
        
        // while there are old zone requests to be processed,
        while oldZoneRequests.count > 0 {
            
            // process old zone request as ozr
            let ozr = oldZoneRequests.first!
            
            // find the updated version of ozr, nzr, from new zone requests
            if let nzrIndex = newZoneRequests.firstIndex(where: {$0.zoneid == ozr.zoneid}) {
                let nzr = newZoneRequests[nzrIndex]
                
                // update all existing requests from ozr
                while ozr.requests.count > 0 {
                    let oreq = ozr.requests.first!
                    var hasMatch = false
                    
                    // match found (exists) - no change
                    for i in 0..<nzr.requests.count {
                        if oreq == nzr.requests[i] {
                            if oreq.isNew ?? false {
                                markRequestAsOld(id: oreq.id!)
                            }
                            ozr.requests.removeFirst()
                            nzr.requests.remove(at: i)
                            hasMatch = true
                            break
                        }
                    }
                    
                    // no match found (deleted) - delete old request
                    if !hasMatch {
                        ozr.requests.removeFirst()
                        deleteRequest(id: oreq.id!)
                    }
                    
                }
                
                // all old requests in zone processed,
                // save all new requests to zonereq (newly added)
                for req in nzr.requests {
                    addRequestToZoneUsingID(zoneID: ozr.zoneid, req: req)
                }
                
                // finished processing ozr, remove ozr from old zone requests
                oldZoneRequests.removeFirst()
                
                // remove matched nzr from new zone requests as well
                newZoneRequests.remove(at: nzrIndex)
                
            } else {
                
                // no match in nzr, delete ozr
                oldZoneRequests.removeFirst()
                deleteZoneRequest(zoneID: ozr.zoneid)
            }

        }
        
        // save remaining new zone requests (no match from existing zones)
        for zonereq in newZoneRequests {
            saveZoneRequest(zonereq: zonereq)
        }
    }
    
    static func clearAllZoneRequests() {
        var cdzonereqs = [CDZoneRequests]()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<CDZoneRequests>(entityName: "CDZoneRequests")
        
        do {
            cdzonereqs = try context.fetch(request)
            for cdzr in cdzonereqs {
                context.delete(cdzr)
            }
            
            try context.save()
        } catch let error as NSError {
            print("Could not update. \(error) \(error.userInfo)")
        }
    }
    
}
