//
//  ModelObject.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 08/12/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

class ModelObject: BaseObject {

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
}
