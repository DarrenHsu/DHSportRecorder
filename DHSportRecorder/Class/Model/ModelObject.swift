//
//  ModelObject.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 08/12/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

class ModelObject: BaseObject {
    
    class func stringClassFromString(_ className: String) -> AnyClass {
        let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String;
        return NSClassFromString("\(namespace).\(className)")!
    }
    
    class func convert(_ dict: [String: Any]) -> ModelObject {
        let obj = ModelObject()
        obj.setValuesForKeys(dict)
        return obj
    }

    class func getObject() -> ModelObject? {
        var obj: ModelObject? = nil
        let path = String(format: "%@/%@", AppManager.sharedInstance().getApplicationSupport(), String(describing: type(of: self)))
        let url = URL(fileURLWithPath: path)
        do {
            if FileManager.default.fileExists(atPath: path) {
                let data =  try Data(contentsOf: url)
                let jsonData = try AESHelper.sharedInstance().aesCBCDecrypt(data: data, keyData: AppManager.sharedInstance().getEncryptKeyData())
                let json: [String : Any]? = try? JSONSerialization.jsonObject(with: jsonData!, options: []) as! [String : Any]
                obj = ModelObject.convert(json!)
            }else {
                return obj
            }
        }catch {
            LogManager.DLog("\(error)")
        }
        return obj
    }
    
    func toDict() -> [String: Any] {
        var dict = [String:Any]()
        let otherSelf = Mirror(reflecting: self)
        let superLess = otherSelf.superclassMirror
        for parent in (superLess?.children)! {
            if let key = parent.label {
                dict[key] = parent.value
            }
        }
        
        for child in otherSelf.children {
            if let key = child.label {
                dict[key] = child.value
            }
        }
        return dict
    }
    
    func toJSONString() -> String {
        let dict = self.toDict()
        var str: String = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
            str = String(data: jsonData, encoding: String.Encoding.utf8)!
            LogManager.DLog("\(str)")
        } catch {
            LogManager.DLog("\(error)")
        }
        
        return str
    }
    
    func save() {
        let path = String(format: "%@/%@", AppManager.sharedInstance().getApplicationSupport(), String(describing: type(of: self)))
        let url = URL(fileURLWithPath: path)
        do {
            let dict: [String: Any] = self.toDict()
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            let data = try AESHelper.sharedInstance().aesCBCEncrypt(data: jsonData, keyData: AppManager.sharedInstance().getEncryptKeyData())
            try data.write(to: url)
            LogManager.DLog("save to \(path)")
        } catch {
            LogManager.DLog("\(error)")
        }
    }
    
    func removeSource() {
        let path = String(format: "%@/%@", AppManager.sharedInstance().getApplicationSupport(), String(describing: type(of: self)))
        do {
            if FileManager.default.fileExists(atPath: path) {
                try FileManager.default.removeItem(atPath: path)
                LogManager.DLog("remove from \(path)")
            }
        } catch {
            LogManager.DLog("\(error)")
        }
    }
    
    func verifyData() -> (Bool, String?) {
        return (true, nil)
    }
}
