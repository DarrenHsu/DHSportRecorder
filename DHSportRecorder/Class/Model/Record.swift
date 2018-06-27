//
//  Record.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 06/12/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

class RecordAdding: ModelObject {
    var lineUserId: String?
    var recordId: String?
    var locality: String?
    var name: String?
    var distance: NSNumber?
    var startTime: String?
    var endTime: String?
    var avgSpeed: NSNumber?
    var maxSpeed: NSNumber?
    var altitude: NSNumber?
    var locations: [[NSNumber]]?
    var imglocations: [Int]?
    
    override class func convert(_ dict: [String: Any]) -> RecordAdding {
        let obj = RecordAdding()
        obj.setValuesForKeys(dict)
        return obj
    }
    
    override class func getObject() -> RecordAdding? {
        var obj: RecordAdding? = nil
        let path = String(format: "%@/%@", AppManager.sharedInstance().getApplicationSupport(), String(describing: RecordAdding.self))
        let url = URL(fileURLWithPath: path)
        do {
            if FileManager.default.fileExists(atPath: path) {
                let data =  try Data(contentsOf: url)
                let jsonData = try AESHelper.sharedInstance().aesCBCDecrypt(data: data, keyData: AppManager.sharedInstance().getEncryptKeyData())
                let json: [String : Any]? = try? JSONSerialization.jsonObject(with: jsonData!, options: []) as! [String : Any]
                obj = RecordAdding.convert(json!)
                LogManager.DLog("conver from \(path)")
            }else {
                LogManager.DLog("new object ")
                obj = RecordAdding()
                obj?.save()
            }
        }catch {
            LogManager.DLog("\(error)")
        }
        return obj
    }
    
    func getTotalMinutes() -> Int {
        let sDate = Date.getDateFromString(self.startTime!, format: Date.JSONFormat)
        let eDate = Date.getDateFromString(self.endTime!, format: Date.JSONFormat)
        return eDate.minutes(from: sDate) ?? 0
    }
    
    func getDHLocationCoordinates() -> [DHLocationCoordinate] {
        var locationCoordinate: [DHLocationCoordinate] = []
        for location in locations! {
            let l = DHLocationCoordinate()
            l.latitude = CLLocationDegrees(truncating: location[0])
            l.longitude = CLLocationDegrees(truncating: location[1])
            locationCoordinate.append(l)
        }
        return locationCoordinate
    }
}

class Record: RecordAdding {
    var _id: String?
    var __v: NSNumber?
    var modifyAt: String?
    var createdAt: String?
    
    override class func convert(_ dict: [String: Any]) -> Record {
        let obj = Record()
        obj.setValuesForKeys(dict)
        return obj
    }
}

class RecordUpdating: RecordAdding {
    var _id: String?
    
    override class func convert(_ dict: [String: Any]) -> RecordUpdating {
        let obj = RecordUpdating()
        obj.setValuesForKeys(dict)
        return obj
    }
}
