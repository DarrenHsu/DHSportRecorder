//
//  FeedManager.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 05/12/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

class FeedManager: NSObject {

    let PrintCount = 1
    
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
    
    fileprivate func printResponse(_ method: String, response: DataResponse<Any>) {
        var str = "\n========================== \(method) ==========================\n"
        str += "URL: \(String(describing: (response.request?.url)!)) \n"
        if response.request?.httpBody != nil {
            str += "BODY: \(String(describing: String(data: (response.request?.httpBody)!, encoding: String.Encoding.utf8)!)) \n"
        }
        
        if let error = response.error {
            str += "\(error)\n"
        }else {
            if  let data = response.data {
                let json: JSON = try! JSON(data: data)
                
                if json.dictionary != nil {
                    if let code: JSON = json.dictionary?["code"] {
                        str += "CODE: \(code.debugDescription)\n"
                    }
                    if let message: JSON = json.dictionary?["message"] {
                        str += "MESSAGE: \(message.debugDescription)\n"
                    }
                    if let dataArray: JSON = json.dictionary?["data"] {
                        if dataArray.array != nil {
                            if dataArray.count > PrintCount {
                                str += "RESPONSE: \n"
                                for i in (0...PrintCount-1)  {
                                    let j: JSON = dataArray.array![i]
                                    str += "\(j.debugDescription) \n"
                                }
                                str += "...More \(dataArray.count - PrintCount) Objects\n"
                            }else {
                                str += "RESPONSE: \(dataArray.debugDescription)\n"
                            }
                        }
                    }
                }
            }
        }
        
        str += "---------------------------------------------------------\n"
        LogManager.DLog("\(str)")
    }
}

// MARK: - HTTP Methods
extension FeedManager {
    fileprivate func GET(_ url: String) -> DataRequest {
        return Alamofire.request(url,
                                 method: .get,
                                 encoding: JSONEncoding.default,
                                 headers: getHeader(getVerfy()))
            .validate()
    }
    
    fileprivate func POST(_ url: String, parameters: Parameters) -> DataRequest {
        return Alamofire.request(url,
                                 method: .post,
                                 parameters: parameters,
                                 encoding: JSONEncoding.default,
                                 headers: getHeader(getVerfy()))
            .validate()
    }
    
    fileprivate func PUT(_ url: String, parameters: Parameters) -> DataRequest {
        return Alamofire.request(url,
                                 method: .put,
                                 parameters: parameters,
                                 encoding: JSONEncoding.default,
                                 headers: getHeader(getVerfy()))
            .validate()
    }
    
    fileprivate func DELETE(_ url: String) -> DataRequest {
        return Alamofire.request(url,
                                 method: .delete,
                                 encoding: JSONEncoding.default,
                                 headers: getHeader(getVerfy()))
            .validate()
    }
}


// MARK: - Request Process
extension FeedManager {
    fileprivate func processResponse(_ response: DataResponse<Any>, success: ((String)->Void)? = nil , failure: (NSNumber, String)->Void) {
        printResponse((response.request?.httpMethod)!, response: response)
        
        if response.error != nil {
            failure(-999, LString("Message:Request error"))
            return
        }
        
        let json = try! JSON(data: response.data!)
        let message = json["message"].stringValue
        if let code = json["code"].number {
            if  code != 0 {
                failure(code, message)
                return
            }else {
                success?(message)
                return
            }
        }
    }
    
    fileprivate func processResponse(_ response: DataResponse<Any>, success: (([[String: Any]], String)->Void)? = nil , failure: (NSNumber, String)->Void) {
        printResponse((response.request?.httpMethod)!, response: response)
        
        if response.error != nil {
            failure(-999, LString("Message:Request error"))
            return
        }
        
        let json = try! JSON(data: response.data!)
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

extension FeedManager {
    fileprivate static let STREET_VIEW = "https://maps.googleapis.com/maps/api/streetview"
    
    public func loadGoogleMapImage(_ lat: CLLocationDegrees, lon: CLLocationDegrees, width: Int, height: Int, success: @escaping (UIImage) -> Void) {
        let url = "\(FeedManager.STREET_VIEW)?size=\(width)x\(height)&location=\(lat),\(lon)&fov=20&heading=75&pitch=5"
        Alamofire.request(url).responseImage { (response) in
            if let image = response.result.value {
                success(image)
            }
        }
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
}

// MARK: - Request Route
extension FeedManager {
    fileprivate static let ROUTE_API = "\(SERVER_NAME)/api/route"
    
    public func addtRoute(_ route: RouteAdding, success: @escaping (Route)->Void, failure: @escaping (String)->Void) {
        self.POST(FeedManager.ROUTE_API, parameters: route.toDict()).responseJSON { (response) in
            self.processResponse(response, success: { (objs, message) in
                success(self.processObject("Route", dict: objs[0]) as! Route)
            }, failure: { (code, msg) in
                failure(msg)
            })
        }
    }
    
    public func updatetRoute(_ route: RouteUpdating, success: @escaping (String)->Void, failure: @escaping (String)->Void) {
        self.PUT("\(FeedManager.ROUTE_API)/\(String(describing: route._id!))", parameters: route.toDict()).responseJSON { (response) in
            self.processResponse(response, success: { (objs, message) in
                success(message)
            }, failure: { (code, message) in
                failure(message)
            })
        }
    }
    
    public func listRoute(_ lineUserId: String, success: @escaping ([Route])->Void, failure: @escaping (String)->Void) {
        self.GET("\(FeedManager.ROUTE_API)/\(lineUserId)").responseJSON { (response) in
            self.processResponse(response, success: { (objs, message) in
                success(self.processObject("Route", array: objs) as! [Route])
            }, failure: { (code, message) in
                failure(message)
            })
        }
    }
    
    public func removeRoute(_ id: String, success: @escaping (String)->Void, failure: @escaping (String)->Void) {
        self.DELETE("\(FeedManager.ROUTE_API)/\(id)").responseJSON { (response) in
            self.processResponse(response, success: { (message) in
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
    
    public func addtRecord(_ record: RecordAdding, success: @escaping (Record)->Void, failure: @escaping (String)->Void) {
        self.POST(FeedManager.RECORD_API, parameters: record.toDict()).responseJSON { (response) in
            self.processResponse(response, success: { (objs, message) in
                success(self.processObject("Record", dict: objs[0]) as! Record)
            }, failure: { (code, message) in
                failure(message)
            })
        }
    }
    
    public func updatetRecord(_ record: RecordUpdating, success: @escaping (String)->Void, failure: @escaping (String)->Void) {
        let urlStr = "\(FeedManager.RECORD_API)/\(String(describing: record._id))"
        self.PUT(urlStr, parameters: record.toDict()).responseJSON { (response) in
            self.processResponse(response, success: { (objs, message) in
                success(message)
            }, failure: { (code, message) in
                failure(message)
            })
        }
    }
    
    public func listRecord(_ lineUserId: String, success: @escaping ([Record])->Void, failure: @escaping (String)->Void) {
        self.GET("\(FeedManager.RECORD_API)/\(lineUserId)").responseJSON { (response) in
            self.processResponse(response, success: { (objs, message) in
                success(self.processObject("Record", array: objs) as! [Record])
            }, failure: { (code, message) in
                failure(message)
            })
        }
    }
    
    public func removeRecord(_ id: String, success: @escaping (String)->Void, failure: @escaping (String)->Void) {
        self.DELETE("\(FeedManager.RECORD_API)/\(id)").responseJSON { (response) in
            self.processResponse(response, success: { (message) in
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
    
    public func addtUser(_ user: UserAdding, success: @escaping ()->Void, failure: @escaping (String)->Void) {
        self.POST(FeedManager.USER_API, parameters: user.toDict()).responseJSON { (response) in
            self.processResponse(response, success: { (objs, message) in
                AppManager.sharedInstance().user = self.processObject("User", dict: objs[0]) as? User
                success()
            }, failure: { (code, message) in
                failure(message)
            })
        }
    }
    
    public func updatetUser(_ user: UserUpdating, success: @escaping (String)->Void, failure: @escaping (String)->Void) {
        self.PUT("\(FeedManager.USER_API)/\(String(describing: user._id))", parameters: user.toDict()).responseJSON { (response) in
            self.processResponse(response, success: { (objs, message) in
                AppManager.sharedInstance().user = self.processObject("User", dict: objs[0]) as? User
                success(message)
            }, failure: { (code, message) in
                failure(message)
            })
        }
    }
    
    public func listUser(_ lineUserId: String, success: @escaping ()->Void, failure: @escaping (String)->Void) {
        self.GET("\(FeedManager.USER_API)/\(lineUserId)").responseJSON { (response) in
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
        self.DELETE("\(FeedManager.USER_API)/\(id)").responseJSON { (response) in
            self.processResponse(response, success: { (message) in
                AppManager.sharedInstance().user?.removeSource()
                success(message)
            }, failure: { (code, message) in
                failure(message)
            })
        }
    }
}

// MARK: - LINE Request
extension FeedManager {
    fileprivate static let LINEWEBHOOK_API = "\(SERVER_NAME)/api/linebot"
    fileprivate static let PUSH_RECORD_API = "\(LINEWEBHOOK_API)/push/record"
    fileprivate static let PUSH_MESSAGE_API = "\(LINEWEBHOOK_API)/push/message"
    fileprivate static let PUSH_TEMPLETE_API = "\(LINEWEBHOOK_API)/push/templete"
    
    public func pushRecord(_ recordId: String, success: @escaping (String)->Void, failure: @escaping (String)->Void) {
        self.GET("\(FeedManager.PUSH_RECORD_API)/\(recordId)").responseJSON { (response) in
            self.processResponse(response, success: { (message) in
                success(message)
            }, failure: { (code, message) in
                failure(message)
            })
        }
    }
    
    public func pushMessage(_ lineUserId: String, message: String, success: @escaping (String)->Void, failure: @escaping (String)->Void) {
        self.POST("\(FeedManager.PUSH_MESSAGE_API)", parameters: ["lineUserId": lineUserId, "msg": message]).responseJSON { (response) in
            self.processResponse(response, success: { (message) in
                success(message)
            }, failure: { (code, message) in
                failure(message)
            })
        }
    }
    
    public func pushRoute(_ lineUserId: String, title: String, success: @escaping (String)->Void, failure: @escaping (String)->Void) {
        self.POST("\(FeedManager.PUSH_TEMPLETE_API)", parameters: ["lineUserId": lineUserId, "title": title]).responseJSON { (response) in
            self.processResponse(response, success: { (message) in
                success(message)
            }, failure: { (code, message) in
                failure(message)
            })
        }
    }
    
    public func pushMessage(_ lineUserId: String, message: String) {
        self.pushMessage(lineUserId, message: "\(message)", success: { (msg) in
        }) { (msg) in
        }
    }
}
