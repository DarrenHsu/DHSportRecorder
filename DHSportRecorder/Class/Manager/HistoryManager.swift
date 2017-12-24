//
//  HistoryManager.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 24/12/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

class HistoryManager: NSObject {
    private static var _manager: HistoryManager?
    public static func sharedInstance() -> HistoryManager {
        if _manager == nil {
            _manager = HistoryManager()
        }
        return _manager!
    }
    
    @objc public dynamic var calendarIndex: Int = 0
    public var currentDate: Date = Date()
    
}
