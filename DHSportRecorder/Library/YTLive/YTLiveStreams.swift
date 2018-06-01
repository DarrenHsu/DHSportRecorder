//
//  YTLiveStreams.swift
//  DHYoutube
//
//  Created by Darren Hsu on 19/10/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

public enum YTStreamStatus: String {
    case active = "active"
    case created = "created"
    case error = "error"
    case inactive = "inactive"
    case ready = "ready"
}

let YouTubeLiveStreamURL    = "https://www.googleapis.com/youtube/v3/liveStreams"

extension YTLive  {
    
    func LiveStreamInsert(_ title: String, description: String, streamName: String, accessToken: String?, success: ((LiveStream) -> Void)?, failure: (() -> Void)?) {
        guard accessToken != nil else {
            failure?()
            return
        }
        
        let jsonDict = ["kind" : "youtube#liveStream",
                        "snippet" : ["title" : title,
                                     "description" : description],
                        "cdn" : ["format" : "480p",
                                 "ingestionType": "rtmp",
                                 "ingestionInfo" : ["streamName" : streamName]]] as [String : Any]
        
        Alamofire.request("\(YouTubeLiveStreamURL)?part=id,snippet,cdn,status&key=\(self.clientId)",
            method: .post,
            encoding: JSONBodyStringEncoding(jsonBody: getJSONString(jsonDict)),
            headers: getHeaders(accessToken!))
            .validate()
            .responseData { response in
                self.processSuccess(response, success: success, failure: failure)
        }
    }
    
    func LiveStreamList(_ id: String? = nil, accessToken: String?, success: (([LiveStream]) -> Void)?, failure: (() -> Void)?) {
        guard accessToken != nil else {
            failure?()
            return
        }
        
        var parameters: Parameters = [
            "part":"id,snippet,cdn,status" as Any,
            "key": self.clientId as Any
        ]
        
        if id != nil {
            parameters.updateValue(id! as Any, forKey: "id")
        }
        
        Alamofire.request(YouTubeLiveStreamURL,
                          parameters: parameters,
                          headers: getHeaders(accessToken!))
            .validate()
            .responseData { response in
                self.processSuccess(response, success: success, failure: failure)
        }
    }
    
    func LiveStreamDelete(_ id: String?, accessToken: String?, success: ((LiveStream) -> Void)?, failure: (() -> Void)?) {
        guard accessToken != nil else {
            failure?()
            return
        }
        
        Alamofire.request("\(YouTubeLiveStreamURL)?id=\(id!)&key=\(self.clientId)",
            method: .delete,
            headers: getHeaders(accessToken!))
            .validate()
            .responseData { response in
                self.processSuccess(response, success: success, failure: failure)
        }
    }

}

extension YTLive {
    fileprivate func processSuccess(_ response: DataResponse<Data>, success: ((LiveStream) -> Void)?, failure: (() -> Void)?) {
        guard self.checkResponseCorrect(response, failure: failure) else {
            return
        }
        
        do {
            let json = try JSON(data: response.data!)
            LogManager.DLog("\(json)")
            let liveStream = LiveStream.conver(dict: json.object as! [String : Any])
            success?(liveStream)
        } catch {
            failure?()
        }
    }
    
    fileprivate func processSuccess(_ response: DataResponse<Data>, success: (([LiveStream]) -> Void)?, failure: (() -> Void)?) {
        guard self.checkResponseCorrect(response, failure: failure) else {
            return
        }
        
        do {
            let json = try JSON(data: response.data!)
            LogManager.DLog("\(json)")
            if let items = json.dictionaryObject!["items"] {
                var results: [LiveStream] = []
                for item in items as! [[String : Any]] {
                    let liveBroadcast = LiveStream.conver(dict: item)
                    results.append(liveBroadcast)
                }
                success?(results)
            }else {
                failure?()
            }
        } catch {
            failure?()
        }
    }
}
