//
//  YTLiveBroadcast.swift
//  DHYoutube
//
//  Created by Darren Hsu on 19/10/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

public enum YTBroadcastLifeCycleStatus: String {
    case abandoned = "abandoned"
    case upcoming = "upcoming"
    case active = "active"
    case completed = "completed"
    case complete = "complete"
    case created = "created"
    case live = "live"
    case liveStarting = "liveStarting"
    case ready = "ready"
    case reclaimed = "reclaimed"
    case revoked = "revoked"
    case testStarting = "testStarting"
    case testing = "testing"
    case all = "all"
}

public enum YTBroadcastType: String {
    case all = "all"
    case event = "event"
    case persistent = "persistent"
}

let YouTubeLiveBroadcastURL = "https://www.googleapis.com/youtube/v3/liveBroadcasts"

extension YTLive {
    func LiveBroadcastInsert(_ title: String, description: String?, startTime: Date, endTime: Date, accessToken: String?, success: ((LiveBroadcast) -> Void)?, failure: (() -> Void)?) {
        guard accessToken != nil else {
            failure?()
            return
        }
        
        let jsonDict = ["kind" : "youtube#liveBroadcast",
                        "snippet" : ["title" : title,
                                     "scheduledStartTime" : startTime.toJSONformat(),
                                     "scheduledEndTime" : endTime.toJSONformat()],
                        "status" : ["privacyStatus" : "public"]] as [String : Any]
        
        Alamofire.request("\(YouTubeLiveBroadcastURL)?part=id,snippet,contentDetails,status&key=\(self.clientId)",
            method: .post,
            encoding: JSONBodyStringEncoding(jsonBody: getJSONString(jsonDict)),
            headers: getHeaders(accessToken!))
            .validate()
            .responseData { response in
                self.processSuccess(response, success: success, failure: failure)
        }
    }
    
    func LiveBroadcastBind(_ broadcastId: String, streamId: String, accessToken: String?, success: ((LiveBroadcast) -> Void)?, failure: (() -> Void)?) {
        guard accessToken != nil else {
            failure?()
            return
        }
        
        Alamofire.request("\(YouTubeLiveBroadcastURL)/bind?id=\(broadcastId)&streamId=\(streamId)&part=id,snippet,contentDetails,status&key=\(self.clientId)",
            method: .post,
            encoding: JSONBodyStringEncoding(jsonBody: getJSONString([:])),
            headers: getHeaders(accessToken!))
            .validate()
            .responseData { response in
                self.processSuccess(response, success: success, failure: failure)
        }
    }
    
    func LiveBroadcastList(_ id: String? = nil, broadcastStatus: YTBroadcastLifeCycleStatus? = .all, broadcastType: YTBroadcastType? = .all, maxResults: Int? = 50,  accessToken: String?, success: (([LiveBroadcast]) -> Void)?, failure: (() -> Void)?) {
        guard accessToken != nil else {
            failure?()
            return
        }
        
        var parameters: Parameters = [
            "part": "id,snippet,contentDetails,status" as Any,
            "broadcastStatus": broadcastStatus!.rawValue as Any,
            "maxResults": maxResults! as Any,
            "key": self.clientId as Any
        ]
        
        if id != nil {
            parameters.updateValue(id! as Any, forKey: "id")
            parameters.removeValue(forKey: "broadcastStatus")
        }
        
        Alamofire.request(YouTubeLiveBroadcastURL,
                          parameters: parameters,
                          headers: getHeaders(accessToken!))
            .validate()
            .responseData { response in
                self.processSuccess(response, success: success, failure: failure)
        }
    }
    
    func liveBroadcastTransition(_ id: String, broadcastStatus: YTBroadcastLifeCycleStatus, accessToken: String?, success: ((LiveBroadcast) -> Void)?, failure: (() -> Void)?) {
        guard accessToken != nil else {
            failure?()
            return
        }
        
        Alamofire.request("\(YouTubeLiveBroadcastURL)/transition?broadcastStatus=\(broadcastStatus.rawValue)&id=\(id)&part=id,snippet,contentDetails,status&key=\(self.clientId)",
            method: .post,
            headers: getHeaders(accessToken!))
            .validate()
            .responseData { response in
                self.processSuccess(response, success: success, failure: failure)
        }
    }
    
    func liveBroadcastDelete(_ id: String, accessToken: String?, success: ((LiveBroadcast) -> Void)?, failure: (() -> Void)?) {
        guard accessToken != nil else {
            failure?()
            return
        }
        
        Alamofire.request("\(YouTubeLiveBroadcastURL)?id=\(id)&part=id,snippet,contentDetails,status&key=\(self.clientId)",
            method: .delete,
            headers: getHeaders(accessToken!))
            .validate()
            .responseData { response in
                self.processSuccess(response, success: success, failure: failure)
        }
    }
}

// MARK: - Process Methods
extension YTLive {
    fileprivate func processSuccess(_ response: DataResponse<Data>, success: ((LiveBroadcast) -> Void)?, failure: (() -> Void)?) {
        guard self.checkResponseCorrect(response, failure: failure) else {
            return
        }
        
        let json = JSON(data: response.data!)
        LogManager.DLog("\(json)")
        let liveBoradcast = LiveBroadcast.conver(dict: json.object as! [String : Any])
        success?(liveBoradcast)
    }
    
    fileprivate func processSuccess(_ response: DataResponse<Data>, success: (([LiveBroadcast]) -> Void)?, failure: (() -> Void)?) {
        guard self.checkResponseCorrect(response, failure: failure) else {
            return
        }
        
        let json = JSON(data: response.data!)
        LogManager.DLog("\(json)")
        if let items = json.dictionaryObject!["items"] {
            var results: [LiveBroadcast] = []
            for item in items as! [[String : Any]] {
                let liveBroadcast = LiveBroadcast.conver(dict: item)
                results.append(liveBroadcast)
            }
            success?(results)
        }else {
            failure?()
        }
    }
}
