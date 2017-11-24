//
//  LiveStream.swift
//  DHYoutube
//
//  Created by Darren Hsu on 18/10/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

class LiveStream: BaseObject {
    var snippet: [String : Any]?
    var snippet_: StreamSnippet?
    
    var status: [String : Any]?
    var status_: StreamStatus?
    
    var kind: String?
    var id: String?
    var etag: String?
    
    var cdn: [String : Any]?
    var cdn_: Cdn?
    
    static func conver(dict: [String: Any]) -> LiveStream {
        let obj = LiveStream()
        obj.setValuesForKeys(dict)
        obj.snippet_ = StreamSnippet.conver(dict: obj.snippet!)
        obj.status_ = StreamStatus.conver(dict: obj.status!)
        obj.cdn_ = Cdn.conver(dict: obj.cdn!)
        return obj
    }
}

class StreamSnippet: BaseObject {
    var isDefaultStream: NSNumber?
    var title: String?
    var description_: String?
    var publishedAt: String?
    var channelId: String?
    
    static func conver(dict: [String: Any]) -> StreamSnippet {
        let obj = StreamSnippet()
        obj.isDefaultStream = dict["isDefaultStream"] as? NSNumber
        obj.title = dict["title"] as? String
        obj.description_ = dict["description"] as? String
        obj.publishedAt = dict["publishedAt"] as? String
        obj.channelId = dict["channelId"] as? String
        return obj
    }
}

class StreamStatus: BaseObject {
    var streamStatus: String?
    var healthStatus: [String : Any]?
    var healthStatus_: HealthStatus?
    
    static func conver(dict: [String: Any]) -> StreamStatus {
        let obj = StreamStatus()
        obj.setValuesForKeys(dict)
        obj.healthStatus_ = HealthStatus.conver(dict: obj.healthStatus!)
        return obj
    }
    
    class HealthStatus: BaseObject {
        var status: String?
        
        static func conver(dict: [String: Any]) -> HealthStatus {
            let obj = HealthStatus()
            obj.setValuesForKeys(dict)
            return obj
        }
    }
}

class Cdn: BaseObject {
    var ingestionInfo: [String : Any]?
    var ingestionInfo_: IngestionInfo?
    
    var frameRate: String?
    var ingestionType: String?
    var resolution: String?
    var format: String?
    
    static func conver(dict: [String: Any]) -> Cdn {
        let obj = Cdn()
        obj.setValuesForKeys(dict)
        obj.ingestionInfo_ = IngestionInfo.conver(dict: obj.ingestionInfo!)
        return obj
    }
    
    class IngestionInfo: BaseObject {
        var backupIngestionAddress: String?
        var ingestionAddress: String?
        var streamName: String?
        
        static func conver(dict: [String: Any]) -> IngestionInfo {
            let obj = IngestionInfo()
            obj.setValuesForKeys(dict)
            return obj
        }
    }
    
}
