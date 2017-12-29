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
    
    private var routes: [Route] = []
    public var routeDict: [String: [Route]] = [:]
    
    @objc public dynamic var calendarIndex: Int = 0
    public var currentDate: Date = Date()
    
    private lazy var aryTimeList : [String] = {
        var aryTime : [String] = []
        
        for h in (7...23) {
            for m in (0...1) {
                if !(h == 23 && m == 1) {
                    aryTime.append("\(String(format: "%02d", h)):\(String(format: "%02d", m * 30))")
                }
            }
        }
        
        return aryTime
    }()
    
    func getStartTimeList() ->[String] {
        let aryTimeList: [String] = self.aryTimeList
        
        return aryTimeList
    }
    
    func getEndTimeList(startTime : String) -> [String] {
        var aryTimeList: [String] = self.aryTimeList
        let index = aryTimeList.index(of: startTime)
        aryTimeList.removeFirst(index!)
        
        return aryTimeList
    }
}

extension HistoryManager {
    func reloadRoute(_ complete: ((Bool, String?)->Void)? = nil) {
        FeedManager.sharedInstance().listRoute((AppManager.sharedInstance().user?.lineUserId)!, success: { (rs) in
            self.routes = rs
            
            complete?(true, nil)
        }) { (msg) in
            complete?(false, msg)
        }
    }
}
