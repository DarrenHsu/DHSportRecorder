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
    
}
