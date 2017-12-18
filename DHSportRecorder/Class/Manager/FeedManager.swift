//
//  FeedManager.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 05/12/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FeedManager: NSObject {

    private static var _manager: FeedManager?
    
    public static func sharedInstance() -> FeedManager {
        if _manager == nil {
            _manager = FeedManager()
        }
        return _manager!
    }
    
    fileprivate static let FEED_AUTH = "Darren Hsu I Love You"
    fileprivate static let SERVER_NAME = "https://dhhealthplatform.herokuapp.com"
    
    fileprivate func getVerfy() -> String {
        return "darrenhsu"
    }
    
    fileprivate func getFeedAuth(_ str: String) -> String {
        let finalString = String(format: "%@%@", FeedManager.FEED_AUTH, str)
        return String.sha256(finalString)!
    }
    
    fileprivate func getHeader(_ str: String) -> HTTPHeaders {
        let headers = ["Content-Type" : "application/json; charset=utf-8",
                       "Authorization" : self.getFeedAuth(str),
                       "verfy" : str]
        
        return headers
    }
    
    public func downloadFile(_ source: URL, destination: URL, success: @escaping ()->Void ) {
        let request = URLRequest(url: source)
        Alamofire.download(request) { (url, response) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
            return (destination, DownloadRequest.DownloadOptions.removePreviousFile)
            }.validate().responseData(completionHandler: {(response) in
                LogManager.DLog("\(response.description)")
                success()
            })
    }
    
    fileprivate func requestGet(_ url: String) -> DataRequest {
        return Alamofire.request(url,
            method: .get,
            encoding: JSONEncoding.default,
            headers: getHeader(getVerfy()))
            .validate()
    }
    
    fileprivate func requestPost(_ url: String, parameters: Parameters) -> DataRequest {
        return Alamofire.request(url,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: getHeader(getVerfy()))
            .validate()
    }
    
    fileprivate func requestPut(_ url: String, parameters: Parameters) -> DataRequest {
        return Alamofire.request(url,
            method: .put,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: getHeader(getVerfy()))
            .validate()
    }
    
    fileprivate func requestDelete(_ url: String) -> DataRequest {
        return Alamofire.request(url,
            method: .delete,
            encoding: JSONEncoding.default,
            headers: getHeader(getVerfy()))
            .validate()
    }
}


// MARK: - Request Process
extension FeedManager {
    fileprivate func processResponse(_ response: DataResponse<Any>, success: (([[String: Any]], String)->Void)? = nil , failure: (NSNumber, String)->Void) {
        if response.error != nil {
            failure(-999, LString("Message:Request error"))
            return
        }
        
        let json = JSON(data: response.data!)
        LogManager.DLog("\(json)")
        let message = json["message"].stringValue
        if let code = json["code"].number {
            if  code != 0 {
                failure(code, message)
                return
            }
        }
        
        if let data = json["data"].arrayObject {
            success?(data as! [[String : Any]], message)
            return
        }
        
        if let data = json["data"].dictionaryObject {
            success?([data], message)
            return
        }
    }
    
    fileprivate func processObject(_ objName: String, array: [[String: Any]]) -> [ModelObject] {
        let objclass = ModelObject.stringClassFromString(objName) as! ModelObject.Type
        var result: [ModelObject] = []
        for dict in array {
            let obj = objclass.convert(dict)
            result.append(obj)
        }
        
        return result
    }
    
    fileprivate func processObject(_ objName: String, dict: [String: Any]) -> ModelObject {
        let objclass = ModelObject.stringClassFromString(objName) as! ModelObject.Type
        let obj = objclass.convert(dict)
        return obj
    }
}

// MARK: - Request Route
extension FeedManager {
    fileprivate static let ROUTE_API = "\(SERVER_NAME)/api/route"
    
    public func addtRoute(_ route: Route, success: @escaping (Route)->Void, failure: @escaping (String)->Void) {
        self.requestPost(FeedManager.ROUTE_API, parameters: route.toAddDict()).responseJSON { (response) in
            self.processResponse(response, success: { (objs, message) in
                success(self.processObject("Route", dict: objs[0]) as! Route)
            }, failure: { (code, msg) in
                failure(msg)
            })
        }
    }
    
    public func updatetRoute(_ route: Route, success: @escaping (String)->Void, failure: @escaping (String)->Void) {
        self.requestPut("\(FeedManager.ROUTE_API)/\(String(describing: route._id))", parameters: route.toUpdateDict()).responseJSON { (response) in
            self.processResponse(response, success: { (objs, message) in
                success(message)
            }, failure: { (code, message) in
                failure(message)
            })
        }
    }
    
    public func listRoute(_ lineUserId: String, success: @escaping ([Route])->Void, failure: @escaping (String)->Void) {
        self.requestGet("\(FeedManager.ROUTE_API)/\(lineUserId)").responseJSON { (response) in
            self.processResponse(response, success: { (objs, message) in
                success(self.processObject("Route", array: objs) as! [Route])
            }, failure: { (code, message) in
                failure(message)
            })
        }
    }
    
    public func removeRoute(_ id: String, success: @escaping (String)->Void, failure: @escaping (String)->Void) {
        self.requestDelete("\(FeedManager.ROUTE_API)/\(id)").responseJSON { (response) in
            self.processResponse(response, success: { (objs, message) in
                success(message)
            }, failure: { (code, message) in
                failure(message)
            })
        }
    }
}

// MARK: - Request Record
extension FeedManager {
    fileprivate static let RECORD_API = "\(SERVER_NAME)/api/record"
    
    public func addtRecord(_ record: Record, success: @escaping (Record)->Void, failure: @escaping (String)->Void) {
        self.requestPost(FeedManager.RECORD_API, parameters: record.toAddDict()).responseJSON { (response) in
            self.processResponse(response, success: { (objs, message) in
                success(self.processObject("Record", dict: objs[0]) as! Record)
            }, failure: { (code, message) in
                failure(message)
            })
        }
    }
    
    public func updatetRecord(_ record: Record, success: @escaping (String)->Void, failure: @escaping (String)->Void) {
        let urlStr = "\(FeedManager.RECORD_API)/\(String(describing: record._id))"
        self.requestPut(urlStr, parameters: record.toUpdateDict()).responseJSON { (response) in
            self.processResponse(response, success: { (objs, message) in
                success(message)
            }, failure: { (code, message) in
                failure(message)
            })
        }
    }
    
    public func listRecord(_ lineUserId: String, success: @escaping ([Record])->Void, failure: @escaping (String)->Void) {
        self.requestGet("\(FeedManager.RECORD_API)/\(lineUserId)").responseJSON { (response) in
            self.processResponse(response, success: { (objs, message) in
                success(self.processObject("Record", array: objs) as! [Record])
            }, failure: { (code, message) in
                failure(message)
            })
        }
    }
    
    public func removeRecord(_ id: String, success: @escaping (String)->Void, failure: @escaping (String)->Void) {
        self.requestDelete("\(FeedManager.RECORD_API)/\(id)").responseJSON { (response) in
            self.processResponse(response, success: { (objs, message) in
                success(message)
            }, failure: { (code, message) in
                failure(message)
            })
        }
    }
}

// MARK: - Request User
extension FeedManager {
    fileprivate static let USER_API = "\(SERVER_NAME)/api/user"
    
    public func addtUser(_ user: User, success: @escaping ()->Void, failure: @escaping (String)->Void) {
        self.requestPost(FeedManager.USER_API, parameters: user.toAddDict()).responseJSON { (response) in
            self.processResponse(response, success: { (objs, message) in
                AppManager.sharedInstance().user = self.processObject("User", dict: objs[0]) as? User
                success()
            }, failure: { (code, message) in
                failure(message)
            })
        }
    }
    
    public func updatetUser(_ user: User, success: @escaping (String)->Void, failure: @escaping (String)->Void) {
        self.requestPut("\(FeedManager.USER_API)/\(String(describing: user._id))", parameters: user.toUpdateDict()).responseJSON { (response) in
            self.processResponse(response, success: { (objs, message) in
                AppManager.sharedInstance().user = self.processObject("User", dict: objs[0]) as? User
                success(message)
            }, failure: { (code, message) in
                failure(message)
            })
        }
    }
    
    public func listUser(_ lineUserId: String, success: @escaping ()->Void, failure: @escaping (String)->Void) {
        self.requestGet("\(FeedManager.USER_API)/\(lineUserId)").responseJSON { (response) in
            self.processResponse(response, success: { (objs, message) in
                AppManager.sharedInstance().user = self.processObject("User", dict: objs[0]) as? User
                success()
            }, failure: { (code, message) in
                if code == -97 {
                    AppManager.sharedInstance().user?.removeSource()
                }
                failure(message)
            })
        }
    }
    
    public func removeUser(_ id: String, success: @escaping (String)->Void, failure: @escaping (String)->Void) {
        self.requestDelete("\(FeedManager.USER_API)/\(id)").responseJSON { (response) in
            self.processResponse(response, success: { (objs, message) in
                AppManager.sharedInstance().user?.removeSource()
                success(message)
            }, failure: { (code, message) in
                failure(message)
            })
        }
    }
}
