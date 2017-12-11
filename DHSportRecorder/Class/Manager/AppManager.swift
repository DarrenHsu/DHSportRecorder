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
    
    private static let ENCRYPT_KEY = "34567890rtyuyguuhytredft543qw345"
    public func getEncryptKeyData() -> Data {
        return AppManager.ENCRYPT_KEY.data(using: .utf8)!
    }
    
    public var user: User?
    public var record: Record?
    
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
}
