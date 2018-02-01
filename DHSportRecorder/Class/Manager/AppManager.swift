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
    public var setupUser: UserAdding?
    public var addRecord: RecordAdding?
    
    private static let PUSH_DISTANCE_KEY = "dh_pushDistance"
    var pushDistance: Float {
        set{
            UserDefaults.standard.set(newValue, forKey: AppManager.PUSH_DISTANCE_KEY)
        }
        get {
            if UserDefaults.standard.value(forKey: AppManager.PUSH_DISTANCE_KEY) == nil {
                UserDefaults.standard.set(1.0, forKey: AppManager.PUSH_DISTANCE_KEY)
            }
            let _distance = UserDefaults.standard.value(forKey: AppManager.PUSH_DISTANCE_KEY) as! Float
            return _distance
        }
    }
    
    private static let IMG_DISTANCE_KEY = "dh_distance"
    var imgDistance: Float {
        set{
            UserDefaults.standard.set(newValue, forKey: AppManager.IMG_DISTANCE_KEY)
        }
        get {
            if UserDefaults.standard.value(forKey: AppManager.IMG_DISTANCE_KEY) == nil {
                UserDefaults.standard.set(1.0, forKey: AppManager.IMG_DISTANCE_KEY)
            }
            let _distance = UserDefaults.standard.value(forKey: AppManager.IMG_DISTANCE_KEY) as! Float
            return _distance
        }
    }
    
    public lazy var distancelist: [String] = {
        return ["0.5","1.0", "3.0", "5.0", "10.0"]
    }()
    
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
