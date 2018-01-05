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
    
    private var records: [Record] = []
    public var recordDict: [String: [Record]] = [:]
    
    @objc public dynamic var dynamicDate: Date = Date()
    public var currentDate: Date = Date()
    
    fileprivate var isLoadHistory = false
    
    public let startHour: Int = 5
    public let endHour: Int = 23
    
    private lazy var aryTimeList : [String] = {
        var aryTime : [String] = []
        
        for h in (startHour...endHour) {
            for m in (0...1) {
                if !(h == endHour && m == 1) {
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
    
    func reloadHistory(_ complete: ((Bool, String?)->Void)? = nil) {
        if isLoadHistory {
            return
        }
        
        isLoadHistory = true
        
        reloadRoute { (success, msg) in
            if success {
                self.reloadRecords { (success, msg) in
                    self.isLoadHistory = false
                    complete!(success, msg)
                }
            }else {
                self.isLoadHistory = false
                complete!(false, msg)
            }
        }
    }
    
    func reloadRecords(_ complete: ((Bool, String?)->Void)? = nil) {
        recordDict.removeAll()
        records.removeAll()
        
        FeedManager.sharedInstance().listRecord((AppManager.sharedInstance().user?.lineUserId)!, success: { (rs) in
            self.records = rs
            self.records = self.records.sorted(by: { (r0, r1) -> Bool in
                return Date.getDateFromString(r0.startTime!, format: Date.JSONFormat) < Date.getDateFromString(r1.startTime!, format: Date.JSONFormat)
            })
            
            for record in self.records {
                let key = Date.getDateFromString(record.startTime!, format: Date.JSONFormat).stringDate("yyyyMMdd")
                if self.recordDict[key] == nil {
                    self.recordDict[key] = []
                }
                
                self.recordDict[key]?.append(record)
            }
            
            complete?(true, nil)
        }) { (msg) in
            complete?(false, msg)
        }
    }
    
    func reloadRoute(_ complete: ((Bool, String?)->Void)? = nil) {
        routeDict.removeAll()
        routes.removeAll()
        
        FeedManager.sharedInstance().listRoute((AppManager.sharedInstance().user?.lineUserId)!, success: { (rs) in
            self.routes = rs
            self.routes = self.routes.sorted(by: { (r0, r1) -> Bool in
                return Date.getDateFromString(r0.startTime!, format: Date.JSONFormat) < Date.getDateFromString(r1.startTime!, format: Date.JSONFormat)
            })
            
            for route in self.routes {
                let key = Date.getDateFromString(route.startTime!, format: Date.JSONFormat).stringDate("yyyyMMdd")
                if self.routeDict[key] == nil {
                    self.routeDict[key] = []
                }
                
                self.routeDict[key]?.append(route)
            }
            
            complete?(true, nil)
        }) { (msg) in
            complete?(false, msg)
        }
    }
}
