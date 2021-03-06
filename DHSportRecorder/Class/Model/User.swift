//
//  User.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 06/12/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

class UserAdding: ModelObject {
    var name: String?
    var gender: NSNumber?
    var age: NSNumber?
    var height: NSNumber?
    var weight: NSNumber?
    var gmail: String?
    var gAccessToken: String?
    var lineUserId: String?
    var pictureUrl: String?
    
    override class func convert(_ dict: [String: Any]) -> UserAdding {
        let obj = UserAdding()
        obj.setValuesForKeys(dict)
        return obj
    }
}

class User: UserAdding {
    var _id: String?
    var __v: NSNumber?
    var modifyAt: String?
    var createdAt: String?
    
    override class func convert(_ dict: [String: Any]) -> User {
        let obj = User()
        obj.setValuesForKeys(dict)
        return obj
    }
    
    override class func getObject() -> User? {
        var obj: User? = nil
        let path = String(format: "%@/%@", AppManager.sharedInstance().getApplicationSupport(), String(describing: User.self))
        let url = URL(fileURLWithPath: path)
        do {
            if FileManager.default.fileExists(atPath: path) {
                let data =  try Data(contentsOf: url)
                let jsonData = try AESHelper.sharedInstance().aesCBCDecrypt(data: data, keyData: AppManager.sharedInstance().getEncryptKeyData())
                let json: [String : Any]? = try? JSONSerialization.jsonObject(with: jsonData!, options: []) as! [String : Any]
                obj = User.convert(json!)
                LogManager.DLog("conver from \(path)")
            }else {
                LogManager.DLog("new object ")
                return obj
            }
        }catch {
            LogManager.DLog("\(error)")
        }
        return obj
    }
}

class UserUpdating: UserAdding {
    var _id: String?
    
    override class func convert(_ dict: [String: Any]) -> UserUpdating {
        let obj = UserUpdating()
        obj.setValuesForKeys(dict)
        return obj
    }
}
