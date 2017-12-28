//
//  Chatroom.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 06/12/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

class ChatroomAdding: ModelObject {
    var lineUserId: String?
    var type: String?
    var chatId: String?
    
    override class func convert(_ dict: [String: Any]) -> ChatroomAdding {
        let obj = ChatroomAdding()
        obj.setValuesForKeys(dict)
        return obj
    }
}

class Chatroom: ChatroomAdding {
    var _id: String?
    var __v: NSNumber?
    var modifyAt: Date?
    var createdAt: String?
    
    override class func convert(_ dict: [String: Any]) -> Chatroom {
        let obj = Chatroom()
        obj.setValuesForKeys(dict)
        return obj
    }
}

class ChatroomUpdating: ChatroomAdding {
    var _id: String?
    
    override class func convert(_ dict: [String: Any]) -> ChatroomUpdating {
        let obj = ChatroomUpdating()
        obj.setValuesForKeys(dict)
        return obj
    }
}
