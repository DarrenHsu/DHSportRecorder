//
//  Route.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 06/12/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

class Route: ModelObject {
    var _id: String?
    var __v: NSNumber?
    var userId: String?
    var name: String?
    var startTime: Date?
    var endTime: Date?
    var ytbroadcastId: String?
    var modifyAt: String?
    var createdAt: String?
    
    override class func convert(_ dict: [String: Any]) -> Route {
        let obj = Route()
        obj.setValuesForKeys(dict)
        return obj
    }
}
