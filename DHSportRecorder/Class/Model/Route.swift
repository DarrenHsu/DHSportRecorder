//
//  Route.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 06/12/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

class RouteAdding: ModelObject {
    var lineUserId: String?
    var name: String?
    var startTime: String?
    var endTime: String?
    var ytbroadcastId: String?
    
    override class func convert(_ dict: [String: Any]) -> RouteAdding {
        let obj = RouteAdding()
        obj.setValuesForKeys(dict)
        return obj
    }
    
    override func verifyData() -> (Bool, String?) {
        if name == nil {
            return (false, LString("Message:Input Route Name"))
        }
        if startTime == nil {
            return (false, LString("Message:Input Route StartTime"))
        }
        if endTime == nil {
            return (false, LString("Message:Input Route EndTime"))
        }
        
        return (true, nil)
    }
}

class Route: RouteAdding {
    var _id: String?
    var __v: NSNumber?
    var modifyAt: String?
    var createdAt: String?
    
    override class func convert(_ dict: [String: Any]) -> Route {
        let obj = Route()
        obj.setValuesForKeys(dict)
        return obj
    }
}

class RouteUpdating: RouteAdding {
    var _id: String?
    
    override class func convert(_ dict: [String: Any]) -> RouteUpdating {
        let obj = RouteUpdating()
        obj.setValuesForKeys(dict)
        return obj
    }
}
