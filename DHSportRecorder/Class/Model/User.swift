//
//  User.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 06/12/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

class User: BaseObject {
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
    
    static func conver(dict: [String: Any]) -> User {
        let obj = User()
        obj.setValuesForKeys(dict)
        return obj
    }
    
    func toDict() -> [String: Any] {
        var dict = [String:Any]()
        let otherSelf = Mirror(reflecting: self)
        for child in otherSelf.children {
            if let key = child.label {
                dict[key] = child.value
            }
        }
        return dict
    }
    
    func save() {
        let userPath = String(format: "%@/UserData", AppManager.sharedInstance().getApplicationSupport())
        let url = URL(fileURLWithPath: userPath)
        do {
            let userDict: [String: Any] = self.toDict()
            let jsonData = try JSONSerialization.data(withJSONObject: userDict, options: .prettyPrinted)
            let data = try AESHelper.sharedInstance().aesCBCEncrypt(data: jsonData, keyData: AppManager.sharedInstance().getEncryptKeyData())
            try data.write(to: url)
        } catch {
            LogManager.DLog("\(error)")
        }
    }
    
    static func getUser() -> User? {
        var user: User? = nil
        let userPath = String(format: "%@/UserData", AppManager.sharedInstance().getApplicationSupport())
        let url = URL(fileURLWithPath: userPath)
        do {
            if FileManager.default.fileExists(atPath: userPath) {
                let data =  try Data(contentsOf: url)
                let userData = try AESHelper.sharedInstance().aesCBCDecrypt(data: data, keyData: AppManager.sharedInstance().getEncryptKeyData())
                let json: [String : Any]? = try? JSONSerialization.jsonObject(with: userData!, options: []) as! [String : Any]
                user = User.conver(dict: json!)
            }else {
                return user
            }
        }catch {
            LogManager.DLog("\(error)")
        }
        return user
    }
}
