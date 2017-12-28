//
//  YTLive.swift
//  DHYoutube
//
//  Created by Darren Hsu on 17/10/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class YTLive: NSObject {
    
    private static var _instance: YTLive?
    static func shard() -> YTLive {
        if _instance == nil {
            _instance = YTLive()
        }
        return _instance!
    }
    
    private var _clientId: String?
    var clientId: String {
        set{ _clientId = newValue }
        get { return _clientId! }
    }
    
    private var _broadcast: LiveBroadcast?
    var broadcast: LiveBroadcast {
        set{ _broadcast = newValue }
        get { return _broadcast! }
    }
    
    private var _stream: LiveStream?
    var stream: LiveStream {
        set{ _stream = newValue }
        get { return _stream! }
    }
    
    private var _broadcastId: String?
    var broadcastId: String {
        set { _broadcastId = newValue }
        get { return _broadcastId! }
    }
    
    func getHeaders(_ accessToken: String) -> [String : String]? {
        return merge(one: ["Content-Type": "application/json"], ["Authorization":"Bearer \(accessToken)"])
    }
    
    func getJSONString(_ dict: [String : Any]) -> String {
        if let theJSONData = try? JSONSerialization.data(withJSONObject: dict, options: []) {
            let theJSONText = String(data: theJSONData, encoding: .ascii)
            return theJSONText!
        }
        
        return "{}"
    }
    
    fileprivate func printResponse(_ method: String, response: DataResponse<Data>) {
        var str = "\n========================== \(method) ==========================\n"
        str += "URL: \(String(describing: (response.request?.url)!)) \n"
        if response.request?.httpBody != nil {
            str += "BODY: \(String(describing: String(data: (response.request?.httpBody)!, encoding: String.Encoding.utf8)!)) \n"
        }
        
        if let error = response.error {
            str += "\(error)\n"
        }else {
            if  let data = response.data {
                let json: JSON = JSON(data: data)
                if json.array != nil {
                    if json.count > 3 {
                        str += "RESPONSE: \n"
                        for i in (0...2)  {
                            let j: JSON = json.array![i]
                            str += "\(j.debugDescription) \n"
                        }
                        str += "...More \(json.count - 3) Objects\n"
                    }else {
                        str += "RESPONSE: \(json.debugDescription)\n"
                    }
                }
                
                if json.dictionary != nil {
                    str += "RESPONSE: \(json.debugDescription)\n"
                }
            }
        }
        
        str += "---------------------------------------------------------\n"
        LogManager.DLog("\(str)")
    }
    
    func checkResponseCorrect(_ response: DataResponse<Data>, failure: (() -> Void)?) -> Bool {
        printResponse((response.request?.httpMethod)!, response: response)
        
        guard let data = response.data else {
            failure?()
            return false
        }
        
        let json = JSON(data: data)
        let error = json["error"].dictionaryObject
        if let e = error {
            if let message = e["message"] {
                failure?()
            }else {
                failure?()
            }
            return false
        }
        
        return true
    }
}

struct JSONBodyStringEncoding: ParameterEncoding {
    private let jsonBody: String
    
    init(jsonBody: String) {
        self.jsonBody = jsonBody
    }
    
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = urlRequest.urlRequest
        let dataBody = (jsonBody as NSString).data(using: String.Encoding.utf8.rawValue)
        if urlRequest?.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest?.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        urlRequest?.httpBody = dataBody
        return urlRequest!
    }
}
