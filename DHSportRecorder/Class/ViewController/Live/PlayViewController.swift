//
//  PlayViewController.swift
//  DHYoutube
//
//  Created by Darren Hsu on 26/10/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit
import XCDYouTubeKit

class PlayViewController: BaseViewController {
    
    @IBOutlet var preView: UIView?
    var controller: XCDYouTubeVideoPlayerViewController?
    
    @IBAction func closePressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        controller = XCDYouTubeVideoPlayerViewController(videoIdentifier:(YTLive.shard().broadcast.id)!)
        NotificationCenter.default.addObserver(self, selector: #selector(moviePlayerPlaybackDidFinish), name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: nil)
        self.addChildViewController(controller!)
        self.view.addSubview((controller?.view)!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func moviePlayerPlaybackDidFinish(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self)
        
        let userinfo = notification.userInfo;
        if let error = userinfo![AnyHashable("error")] {
            ui.showAlert(LString("Message:Play faild"), controller: self, submit: {
                self.controller?.removeFromParentViewController()
                self.dismiss(animated: true, completion: nil)
            })
            LogManager.DLog("youtube play error \(error)")
            return
        }
        
        controller?.removeFromParentViewController()
        self.dismiss(animated: true, completion: nil)
    }
}
