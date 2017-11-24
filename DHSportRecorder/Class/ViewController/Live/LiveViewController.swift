//
//  LiveViewController.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 08/11/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import GoogleSignIn
import SDWebImage
import UIKit
import MediaPlayer
import AVKit
import XCDYouTubeKit

class LiveViewController: BaseViewController, GIDSignInUIDelegate {
    
    @IBOutlet var tableView: UITableView?
    
    let signInButton = GIDSignInButton()
    var broadcasts: [LiveBroadcast] = []
    var isLoading = false
    
    @IBAction func createBroadcast(sender: UIButton) {
        let startDate = Helpers.dateAfter(Date(), after: (hour: 0, minute: 0, second: 0))
        let endDate = Helpers.dateAfter(Date(), after: (hour: 1, minute: 0, second: 0))
        
        let dateFormatterDate = DateFormatter()
        dateFormatterDate.dateFormat = "yyyy-MM-dd HH:mm"
        let dateStr = dateFormatterDate.string(from: Date())
        
        let title = "Live Title \(dateStr)"
        let description = "This is a test broadcast"
        let streamTitle = "Live Stream \(dateStr)"
        let streamDescription = "This is a test stream"
        
        self.ui.startLoading(self.view)
        YTLive.shard().LiveBroadcastInsert(title, description: description, startTime: startDate, endTime: endDate, accessToken: self.gi.getAccessToken(), success: { (broadcast) in
            YTLive.shard().LiveStreamInsert(streamTitle, description: streamDescription, streamName: streamTitle, accessToken: self.gi.getAccessToken(), success: { (stream) in
                YTLive.shard().LiveBroadcastBind(broadcast.id!, streamId: stream.id!, accessToken: self.gi.getAccessToken(), success: { (bindBroadcast) in
                    self.ui.stopLoading()
                    self.ui.showAlert((bindBroadcast.contentDetails_?.boundStreamId)!, controller: self)
                    self.reloadBroadcast()
                }, failure: {
                    self.ui.stopLoading()
                    self.ui.showAlert(LString("Message:Bind Broadcast Failure"), controller: self)
                })
            }, failure: {
                self.ui.stopLoading()
                self.ui.showAlert(LString("Message:Add Stream Failure"), controller: self)
            })
        }) {
            self.ui.stopLoading()
            self.ui.showAlert(LString("Message:Add Broadcast Failure"), controller: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.isHidden = true
        view.addSubview(signInButton)
        signInButton.center = view.center
        
        self.ui.startLoading(self.view)
        gi.authorization(controller: self) { (success) in
            self.ui.stopLoading()
            self.signInButton.isHidden = success
            self.tableView?.isHidden = !success
            
            if success {
                YTLive.shard().clientId = self.gi.getClientID()
                self.ui.showAlert(LString("Message:Google Auth Success"), controller: self, submit: {
                    self.reloadBroadcast()
                })
            } else {
                self.ui.showAlert(LString("Message:Google Auth Failure"), controller: self)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadBroadcast() {
        guard !isLoading  else {
            return
        }
        
        isLoading = true;
        self.ui.startLoading(self.view)
        YTLive.shard().LiveBroadcastList(broadcastStatus: YTBroadcastLifeCycleStatus.all, accessToken: self.gi.getAccessToken(), success: { (broadcasts) in
            self.ui.stopLoading()
            self.broadcasts = broadcasts
            self.tableView?.reloadData()
            self.isLoading = false
        }, failure: {
            self.ui.stopLoading()
            self.ui.showAlert(LString("Message:list Broadcast Failure"), controller: self)
            self.isLoading = false
        })
    }
}

extension LiveViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.tableView {
            if scrollView.contentOffset.y < -150 {
                self.reloadBroadcast()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.broadcasts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell") as! BroadcastTabelCell
        
        let broadcast = broadcasts[indexPath.row]
        cell.ytNameLabel?.text = broadcast.snippet_?.title
        cell.ytActivityLabel?.text = broadcast.status_?.lifeCycleStatus
        
        cell.ytImageView?.sd_setImage(with: URL(string: (broadcast.snippet_?.thumbnails?.default_?.url)!),
                                      placeholderImage: UIImage(named: "ic_youtube"),
                                      completed: nil)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let broadcast = broadcasts[indexPath.row]
        YTLive.shard().broadcast = broadcast
        
        switch (broadcast.status_?.lifeCycleStatus)! {
        case YTBroadcastLifeCycleStatus.live.rawValue:
            self.ui.startLoading(self.view)
            YTLive.shard().liveBroadcastTransition(YTLive.shard().broadcast.id!, broadcastStatus: YTBroadcastLifeCycleStatus.complete, accessToken: self.gi.getAccessToken(), success: { (broadcast) in
                self.ui.stopLoading()
                YTLive.shard().broadcast = broadcast
                self.reloadBroadcast()
            }, failure:{
                self.ui.stopLoading()
            })
            break
        case YTBroadcastLifeCycleStatus.ready.rawValue:
            self.ui.startLoading(self.view)
            YTLive.shard().LiveStreamList((broadcast.contentDetails_?.boundStreamId)!, accessToken: self.gi.getAccessToken(), success: { (streams) in
                self.ui.stopLoading()
                YTLive.shard().stream = streams[0]
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "StreamViewController") as! StreamViewController
                self.present(controller, animated: true, completion: nil)
            }, failure:{
                self.ui.stopLoading()
            })
            break
        case YTBroadcastLifeCycleStatus.complete.rawValue:
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "PlayViewController") as! PlayViewController
            self.present(controller, animated: true, completion: nil)
        default:
            break
        }
    }
}

class BroadcastTabelCell: UITableViewCell {
    @IBOutlet var ytImageView: UIImageView?
    @IBOutlet var ytNameLabel: UILabel?
    @IBOutlet var ytActivityLabel: UILabel?
}
