//
//  User.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 06/12/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

class User: ModelObject {
    var _id: String?
    var name: String?
    var gender: NSNumber?
    var age: NSNumber?
    var height: NSNumber?
    var weight: NSNumber?
    var gmail: String?
    var gAccessToken: String?
    var lineUserId: String?
    var pictureUrl: String?
    var modifyAt: String?
    
    override class func conver(dict: [String: Any]) -> User {
        let obj = User()
        obj.setValuesForKeys(dict)
        return obj
    }
}
