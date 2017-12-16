//
//  Chatroom.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 06/12/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

class Chatroom: ModelObject {
    var _id: String?
    var __v: NSNumber?
    var lineUserId: String?
    var type: String?
    var chatId: String?
    var modifyAt: Date?
    var createdAt: String?
    
    override class func convert(_ dict: [String: Any]) -> Chatroom {
        let obj = Chatroom()
        obj.setValuesForKeys(dict)
        return obj
    }
}
