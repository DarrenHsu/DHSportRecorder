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
    
    public func downloadFile(_ source: URL, destination: URL, success: ((_ : UIImage?) -> Void)?) {
        let request = URLRequest(url: source)
        Alamofire.download(request) { (url, response) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
            return (destination, DownloadRequest.DownloadOptions.removePreviousFile)
            }.validate().responseData(completionHandler: {(response) in
                LogManager.DLog("\(response.description)")
                do {
                    let img = try UIImage(data: Data(contentsOf: destination))
                    success?(img!)
                }catch {}
            })
    }
}
