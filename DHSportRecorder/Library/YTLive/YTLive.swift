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
    
    func checkResponseCorrect(_ response: DataResponse<Data>, failure: (() -> Void)?) -> Bool {
        guard let data = response.data else {
            failure?()
            return false
        }
        
        let json = JSON(data: data)
        let error = json["error"].dictionaryObject
        if let e = error {
            if let message = e["message"] {
                print("Error while Youtube broadcast was creating: \(message)")
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
