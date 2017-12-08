//
//  ModelObject.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 08/12/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

class ModelObject: BaseObject {
    
    class func conver(dict: [String: Any]) -> ModelObject {
        let obj = ModelObject()
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
        let path = String(format: "%@/%@", AppManager.sharedInstance().getApplicationSupport(), String(describing: User.self))
        let url = URL(fileURLWithPath: path)
        do {
            let dict: [String: Any] = self.toDict()
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            let data = try AESHelper.sharedInstance().aesCBCEncrypt(data: jsonData, keyData: AppManager.sharedInstance().getEncryptKeyData())
            try data.write(to: url)
        } catch {
            LogManager.DLog("\(error)")
        }
    }
    
    class func getObject() -> ModelObject? {
        var obj: ModelObject? = nil
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
