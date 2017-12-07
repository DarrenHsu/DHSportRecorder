//
//  FeedManager.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 05/12/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit
import Alamofire


class FeedManager: NSObject {

    private static var _manager: FeedManager?
    
    public static func sharedInstance() -> FeedManager {
        if _manager == nil {
            _manager = FeedManager()
        }
        return _manager!
    }
    
    fileprivate static let FEED_AUTH = "Darren Hsu I Love You"
    
    public func getFeedAuth(_ str: String) -> String {
        let finalString = String(format: "%@%@", FeedManager.FEED_AUTH, str)
        return String.sha256(finalString)!
    }
    
    public func getHeader(_ str: String) -> [String : Any] {
        let headers = ["Content-Type" : "application/json",
                       "Authorization" : "Basic " + self.getFeedAuth(str),
                       "verfy" : str]
        
        return headers
    }
    
    public func downloadFile(_ source: URL, destination: URL, success: (() -> Void)?) {
        let request = URLRequest(url: source)
        Alamofire.download(request) { (url, response) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
            return (destination, DownloadRequest.DownloadOptions.removePreviousFile)
            }.validate().responseData(completionHandler: {(response) in
                LogManager.DLog("\(response.description)")
                success?()
            })
    }
    
    public func requestUser(_ gmail: String, success: ((User)->Void)?, failure: (()->Void)?) {
        
    }
}
