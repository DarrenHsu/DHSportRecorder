//
//  LogManager.swift
//  DHYoutube
//
//  Created by Darren Hsu on 24/10/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

class LogManager: NSObject {

    private static let DEBUG = true
    
    private static var _manager: LogManager?
    
    public static func sharedInstance() -> LogManager {
        if _manager == nil {
            _manager = LogManager()
        }
        return _manager!
    }
    
    public static func DLog(_ message: String, function: String = #function) {
        if DEBUG {
            print("\(message)")
        }
    }

}
