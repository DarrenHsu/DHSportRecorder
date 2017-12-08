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
    
    static func conver(dict: [String: Any]) -> User {
        let obj = User()
        obj.setValuesForKeys(dict)
        return obj
    }
    
    static func getUser() -> User? {
        var obj: User? = nil
        let path = String(format: "%@/%@", AppManager.sharedInstance().getApplicationSupport(), String(describing: User.self))
        let url = URL(fileURLWithPath: path)
        do {
            if FileManager.default.fileExists(atPath: path) {
                let data =  try Data(contentsOf: url)
                let jsonData = try AESHelper.sharedInstance().aesCBCDecrypt(data: data, keyData: AppManager.sharedInstance().getEncryptKeyData())
                let json: [String : Any]? = try? JSONSerialization.jsonObject(with: jsonData!, options: []) as! [String : Any]
                obj = User.conver(dict: json!)
            }else {
                return obj
            }
        }catch {
            LogManager.DLog("\(error)")
        }
        return obj
    }
}
