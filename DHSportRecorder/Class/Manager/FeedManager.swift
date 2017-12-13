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
    
    fileprivate func process(_ response: DataResponse<Any>, success: @escaping (String)->Void, failure: @escaping (String)->Void) {
        if response.error != nil {
            failure("error")
            return
        }
        
        let json = JSON(data: response.data!)
        LogManager.DLog("\(json)")
        let message = json["message"].stringValue
        if let code = json["code"].number {
            if code == 0 {
                success(message)
            }else {
                failure(message)
            }
        }
    }
}

// MARK: - Request User
extension FeedManager {
    
    fileprivate static let USER_API = "\(SERVER_NAME)/api/user"
    
    public func addtUser(_ user: User, success: @escaping ()->Void, failure: @escaping (String)->Void) {
        let urlStr = FeedManager.USER_API
        self.requestPost(urlStr, parameters: user.toAddDict()).responseJSON { (response) in
            self.process(response, success: success, failure: failure)
        }
    }
    
    public func updatetUser(_ user: User, success: @escaping ()->Void, failure: @escaping (String)->Void) {
        let urlStr = "\(FeedManager.USER_API)/\(String(describing: user._id))"
        self.requestPut(urlStr, parameters: user.toUpdateDict()).responseJSON { (response) in
            self.process(response, success: success, failure: failure)
        }
    }
    
    public func listUser(_ lineUserId: String, success: @escaping ()->Void, failure: @escaping (String)->Void) {
        let urlStr = "\(FeedManager.USER_API)/\(lineUserId)"
        self.requestGet(urlStr).responseJSON { (response) in
            self.process(response, success: success, failure: failure)
        }
    }
    
    public func removeUser(_ id: String, success: @escaping (String)->Void, failure: @escaping (String)->Void) {
        let urlStr = "\(FeedManager.USER_API)/\(id)"
        self.requestDelete(urlStr).responseJSON { (response) in
            self.process(response, success: success, failure: failure)
        }
    }
    
    fileprivate func process(_ response: DataResponse<Any>, success: @escaping ()->Void, failure: @escaping (String)->Void) {
        if response.error != nil {
            failure("error")
            return
        }
        
        let json = JSON(data: response.data!)
        LogManager.DLog("\(json)")
        let message = json["message"].stringValue
        if let code = json["code"].number {
            switch (code) {
            case 0:
                break
            case -97:
                AppManager.sharedInstance().user?.removeSource()
                failure(message)
                break
            default:
                failure(message)
                break
            }
        }
        
        if let data = json["data"].dictionaryObject {
            let user = User.convert(data)
            AppManager.sharedInstance().user = user
            success()
            return
        }
        
        if let data = json["data"].arrayObject {
            let user = User.convert(data[0] as! [String : Any])
            AppManager.sharedInstance().user = user
            success()
            return
        }
    }
}
