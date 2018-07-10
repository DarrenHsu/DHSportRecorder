//
//  StreamViewController.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 08/11/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

protocol YouTubeLiveVideoOutput: class {
    func startPublishing(completed: @escaping (String?, String?) -> Void)
    func finishPublishing()
    func cancelPublishing()
}

class StreamViewController: BaseViewController {
    
    var output: YouTubeLiveVideoOutput?
    var scheduledStartTime: NSDate?
    
    @IBOutlet weak var lfView: LFLivePreview!
    @IBOutlet weak var beautyButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var startLiveButton: UIButton!
    @IBOutlet weak var publishButton: UIButton?
    @IBOutlet weak var completeButton: UIButton?
    @IBOutlet weak var broadcastLabel: UILabel?
    @IBOutlet weak var streamLabel: UILabel?
    
    @IBAction func changeCameraPositionButtonPressed(_ sender: Any) {
        lfView.changeCameraPosition()
    }
    
    @IBAction func changeBeautyButtonPressed(_ sender: Any) {
        beautyButton.isSelected = lfView.changeBeauty()
    }
    
    @IBAction func onClickPublish(_ sender: Any) {
        if startLiveButton.isSelected {
            startLiveButton.isSelected = false
            startLiveButton.setTitle("Start live broadcast", for: .normal)
            lfView.stopPublishing()
            output?.finishPublishing()
        } else  {
            self.broadcastLabel?.text = YTBroadcastLifeCycleStatus.testing.rawValue
            startLiveButton.isSelected = true
            startLiveButton.setTitle("Finish live broadcast", for: .normal)
            let streamUrl = "rtmp://a.rtmp.youtube.com/live2/\((YTLive.shard().stream.cdn_?.ingestionInfo_?.streamName)!)"
            self.lfView.startPublishing(withStreamURL: streamUrl)
            self.checkStream()
        }
    }
    
    @IBAction func publishButtonPressed(_ sender: Any) {
        YTLive.shard().liveBroadcastTransition(YTLive.shard().broadcast.id!, broadcastStatus: YTBroadcastLifeCycleStatus.live, accessToken: self.gi.accessToken, success: { (broadcast) in
            YTLive.shard().broadcast = broadcast
            
            self.broadcastLabel?.text = broadcast.status_?.lifeCycleStatus
            self.completeButton?.isEnabled = true
        }, failure: nil)
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        output?.cancelPublishing()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func completePressed(_ sender: Any) {
        YTLive.shard().liveBroadcastTransition(YTLive.shard().broadcast.id!, broadcastStatus: YTBroadcastLifeCycleStatus.complete, accessToken: self.gi.accessToken, success: { (broadcast) in
            YTLive.shard().broadcast = broadcast
            self.dismiss(animated: true, completion: nil)
        }) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        beautyButton.isExclusiveTouch = true
        cameraButton.isExclusiveTouch = true
        closeButton.isExclusiveTouch = true
        
        LogManager.DLog("embedHtml: \((YTLive.shard().broadcast.contentDetails_?.monitorStream_?.embedHtml)!)")
        LogManager.DLog("streamUrl: \((YTLive.shard().stream.cdn_?.ingestionInfo_?.streamName)!)")
        
        self.broadcastLabel?.text = YTLive.shard().broadcast.status_?.lifeCycleStatus
        self.streamLabel?.text = YTLive.shard().stream.status_?.streamStatus
        self.publishButton?.isEnabled = false
        self.completeButton?.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.lfView.prepareForUsing()
        }
    }
    
    func checkStream() {
        YTLive.shard().LiveStreamList(YTLive.shard().stream.id!, accessToken: self.gi.accessToken, success: { (streams) in
            if let s = streams[0].status_?.streamStatus {
                self.streamLabel?.text = s
                switch(s) {
                case YTStreamStatus.active.rawValue:
                    
                    switch(YTLive.shard().broadcast.status_?.lifeCycleStatus) {
                    case YTBroadcastLifeCycleStatus.ready.rawValue?:
                        YTLive.shard().liveBroadcastTransition(YTLive.shard().broadcast.id!, broadcastStatus: YTBroadcastLifeCycleStatus.testing, accessToken: self.gi.accessToken, success: { (broadcast) in
                            YTLive.shard().broadcast = broadcast
                            self.broadcastLabel?.text = broadcast.status_?.lifeCycleStatus
                            
                            if broadcast.status_?.lifeCycleStatus == YTBroadcastLifeCycleStatus.testStarting.rawValue {
                                self.publishButton?.isEnabled = true
                            }
                        }, failure: nil)
                        break
                    default:
                        break
                    }
                    
                    break
                case YTStreamStatus.ready.rawValue:
                    self.checkStream()
                    break
                case YTStreamStatus.inactive.rawValue:
                    break
                default:
                    break
                }
            }
        }, failure: nil)
    }
}

