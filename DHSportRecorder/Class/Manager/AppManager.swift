//
//  AppManager.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 06/12/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

class AppManager: NSObject {
    
    private static var _manager: AppManager?
    
    public static func sharedInstance() -> AppManager {
        if _manager == nil {
            _manager = AppManager()
        }
        return _manager!
    }
    
    public func getDocumentPath() -> String {
        let directory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return directory
    }
    
    public func getApplicationSupport() -> String {
        let directory = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
        let path = "\(directory)/Application Support"
        if !FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes:nil)
            } catch let error as NSError{
                LogManager.DLog("err \(error)")
            }
        }
        return path
    }
    
    public func saveUserId(_ userId: String) {
        
    }
    
    public func getUserId() -> String {
        return ""
    }
    
    
}
