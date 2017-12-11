//
//  Record.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 06/12/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

class Record: ModelObject {
    var _id: String?
    var userId: String?
    var locality: String?
    var name: String?
    var distance: NSNumber?
    var startTime: String?
    var endTime: String?
    var avgSpeed: NSNumber?
    var maxSpeed: NSNumber?
    var locations: [[String: Any]]?
    var imglocations: [Int]?
    
    override class func convert(_ dict: [String: Any]) -> Record {
        let obj = Record()
        obj.setValuesForKeys(dict)
        return obj
    }
    
    override class func getObject() -> Record? {
        var obj: Record? = nil
        let path = String(format: "%@/%@", AppManager.sharedInstance().getApplicationSupport(), String(describing: Record.self))
        let url = URL(fileURLWithPath: path)
        do {
            if FileManager.default.fileExists(atPath: path) {
                let data =  try Data(contentsOf: url)
                let jsonData = try AESHelper.sharedInstance().aesCBCDecrypt(data: data, keyData: AppManager.sharedInstance().getEncryptKeyData())
                let json: [String : Any]? = try? JSONSerialization.jsonObject(with: jsonData!, options: []) as! [String : Any]
                obj = Record.convert(json!)
                LogManager.DLog("conver from \(path)")
            }else {
                LogManager.DLog("new object ")
                obj = Record()
                obj?.save()
            }
        }catch {
            LogManager.DLog("\(error)")
        }
        return obj
    }
}
