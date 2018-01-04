//
//  LineManager.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 05/12/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit
import LineSDK

class LineManager: NSObject {

    public static let LINE_BOT_URL = "https://line.me/R/ti/p/M3qgSZXFH3"
    
    private static var _manager: LineManager?
    
    public static func sharedInstance() -> LineManager {
        if _manager == nil {
            _manager = LineManager()
        }
        return _manager!
    }
    
    var profile: LineSDKProfile?
    
    public func getLocalicturePath() -> String {
        let picture = "\(AppManager.sharedInstance().getApplicationSupport())/picture"
        return picture
    }
}
