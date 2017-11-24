//
//  LiveBroadcast.swift
//  DHYoutube
//
//  Created by Darren Hsu on 18/10/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

class LiveBroadcast: BaseObject {
    var status: [String : Any]?
    var status_: BroadcastStatus?
    var kind: String?
    var contentDetails: [String : Any]?
    var contentDetails_: ContentDetails?
    var id: String?
    var etag: String?
    var snippet: [String : Any]?
    var snippet_: BroadcastSnippet?
    
    static func conver(dict: [String: Any]) -> LiveBroadcast {
        let obj = LiveBroadcast()
        obj.setValuesForKeys(dict)
        obj.status_ = BroadcastStatus.conver(dict: obj.status!)
        obj.contentDetails_ = ContentDetails.conver(dict: obj.contentDetails!)
        obj.snippet_ = BroadcastSnippet.conver(dict: obj.snippet!)
        return obj
    }
}

class BroadcastStatus: BaseObject {
    var privacyStatus: String?
    var recordingStatus: String?
    var lifeCycleStatus: String?
    
    static func conver(dict: [String: Any]) -> BroadcastStatus {
        let obj = BroadcastStatus()
        obj.setValuesForKeys(dict)
        return obj
    }
}

class ContentDetails: BaseObject {
    var enableDvr: NSNumber?
    var recordFromStart: NSNumber?
    var enableContentEncryption: NSNumber?
    var enableEmbed: NSNumber?
    var enableClosedCaptions: NSNumber?
    var closedCaptionsType: String?
    var projection: String?
    var monitorStream: [String : Any]?
    var monitorStream_: MonitorStream?
    var latencyPreference: String?
    var startWithSlate: NSNumber?
    var enableLowLatency: NSNumber?
    var boundStreamId: String?
    var boundStreamLastUpdateTimeMs: String?
    
    
    static func conver(dict: [String: Any]) -> ContentDetails {
        let obj = ContentDetails()
        obj.setValuesForKeys(dict)
        obj.monitorStream_ = MonitorStream.conver(dict: obj.monitorStream!)
        return obj
    }
    
    class MonitorStream: BaseObject {
        var enableMonitorStream: NSNumber?
        var broadcastStreamDelayMs: NSNumber?
        var embedHtml: String?
        
        static func conver(dict: [String: Any]) -> MonitorStream {
            let obj = MonitorStream()
            obj.setValuesForKeys(dict)
            return obj
        }
    }
}

class BroadcastSnippet: BaseObject {
    var thumbnails: Thumbnails?
    var channelId: String?
    var isDefaultBroadcast: NSNumber?
    var title: String?
    var publishedAt: String?
    var scheduledStartTime: String?
    var liveChatId: String?
    var description_: String?
    
    static func conver(dict: [String: Any]) -> BroadcastSnippet {
        let obj = BroadcastSnippet()
        obj.thumbnails = Thumbnails.conver(dict: dict["thumbnails"] as! [String : Any]!)
        obj.channelId = dict["channelId"] as? String
        obj.isDefaultBroadcast = dict["isDefaultBroadcast"] as? NSNumber
        obj.title = dict["title"] as? String
        obj.publishedAt = dict["publishedAt"] as? String
        obj.scheduledStartTime = dict["scheduledStartTime"] as? String
        obj.liveChatId = dict["liveChatId"] as? String
        obj.description_ = dict["description"] as? String
        return obj
    }
}

class Thumbnails: BaseObject {
    var default_: Default?
    var high: High?
    var medium : Medium?
    
    static func conver(dict: [String: Any]) -> Thumbnails {
        let obj = Thumbnails()
        obj.default_ = Default.conver(dict: dict["default"] as! [String : Any])
        obj.high = High.conver(dict: dict["high"] as! [String : Any])
        obj.medium = Medium.conver(dict: dict["medium"] as! [String : Any])
        return obj
    }
    
    class Default: BaseObject {
        var url: String?
        var width: NSNumber?
        var height: NSNumber?
        
        static func conver(dict: [String: Any]) -> Default {
            let obj = Default()
            obj.setValuesForKeys(dict)
            return obj
        }

    }
    
    class High: BaseObject {
        var url: String?
        var width: NSNumber?
        var height: NSNumber?
        
        static func conver(dict: [String: Any]) -> High {
            let obj = High()
            obj.setValuesForKeys(dict)
            return obj
        }

    }
    
    class Medium: BaseObject {
        var url: String?
        var width: NSNumber?
        var height: NSNumber?
        
        static func conver(dict: [String: Any]) -> Medium {
            let obj = Medium()
            obj.setValuesForKeys(dict)
            return obj
        }

    }

}
