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
    
    @IBOutlet weak var tableView: UITableView?
    
    var broadcasts: [LiveBroadcast] = []
    var isLoading = false
    
    @IBAction func createBroadcast(_ sender: UIBarButtonItem) {
        let startDate = Helpers.dateAfter(Date(), after: (hour: 0, minute: 0, second: 0))
        let endDate = Helpers.dateAfter(Date(), after: (hour: 1, minute: 0, second: 0))
        
        let dateFormatterDate = DateFormatter()
        dateFormatterDate.dateFormat = "yyyy-MM-dd HH:mm"
        let dateStr = dateFormatterDate.string(from: Date())
        
        let title = "Live Title \(dateStr)"
        let description = "This is a test broadcast"
        let streamTitle = "Live Stream \(dateStr)"
        let streamDescription = "This is a test stream"
        
        self.startAnimating()
        YTLive.shard().LiveBroadcastInsert(title, description: description, startTime: startDate, endTime: endDate, accessToken: self.gi.accessToken, success: { (broadcast) in
            YTLive.shard().LiveStreamInsert(streamTitle, description: streamDescription, streamName: streamTitle, accessToken: self.gi.accessToken, success: { (stream) in
                YTLive.shard().LiveBroadcastBind(broadcast.id!, streamId: stream.id!, accessToken: self.gi.accessToken, success: { (bindBroadcast) in
                    self.stopAnimating()
                    self.ui.showAlert((bindBroadcast.contentDetails_?.boundStreamId)!, controller: self)
                    self.reloadBroadcast()
                }, failure: {
                    self.stopAnimating()
                    self.ui.showAlert(LString("Message:Bind Broadcast Failure"), controller: self)
                })
            }, failure: {
                self.stopAnimating()
                self.ui.showAlert(LString("Message:Add Stream Failure"), controller: self)
            })
        }) {
            self.stopAnimating()
            self.ui.showAlert(LString("Message:Add Broadcast Failure"), controller: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.isHidden = true
        
        self.startAnimating()
        gi.authorization(controller: self) { (success) in
            self.stopAnimating()
            self.tableView?.isHidden = !success
            
            if success {
                YTLive.shard().clientId = self.gi.getClientID()
                self.reloadBroadcast()
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
        self.startAnimating()
        YTLive.shard().LiveBroadcastList(broadcastStatus: YTBroadcastLifeCycleStatus.all, accessToken: self.gi.accessToken, success: { (broadcasts) in
            self.stopAnimating()
            self.broadcasts = broadcasts
            self.tableView?.reloadData()
            self.isLoading = false
        }, failure: {
            self.stopAnimating()
            self.ui.showAlert(LString("Message:list Broadcast Failure"), controller: self)
            self.isLoading = false
        })
    }
}

// MARK: - UIScrollViewDelegate
extension LiveViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.tableView {
            if scrollView.contentOffset.y < -120 {
                self.reloadBroadcast()
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension LiveViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.broadcasts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell") as! BroadcastTabelCell
        
        let broadcast = broadcasts[indexPath.row]
        cell.ytNameLabel.text = broadcast.snippet_?.title
        cell.ytActivityLabel.text = broadcast.status_?.lifeCycleStatus
        
        cell.ytImageView.sd_setImage(with: URL(string: (broadcast.snippet_?.thumbnails?.default_?.url)!),
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
            self.startAnimating()
            YTLive.shard().liveBroadcastTransition(YTLive.shard().broadcast.id!, broadcastStatus: YTBroadcastLifeCycleStatus.complete, accessToken: self.gi.accessToken, success: { (broadcast) in
                self.stopAnimating()
                YTLive.shard().broadcast = broadcast
                self.reloadBroadcast()
            }, failure:{
                self.stopAnimating()
            })
            break
        case YTBroadcastLifeCycleStatus.ready.rawValue:
            self.startAnimating()
            YTLive.shard().LiveStreamList((broadcast.contentDetails_?.boundStreamId)!, accessToken: self.gi.accessToken, success: { (streams) in
                self.stopAnimating()
                YTLive.shard().stream = streams[0]
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "StreamViewController") as! StreamViewController
                self.present(controller, animated: true, completion: nil)
            }, failure:{
                self.stopAnimating()
            })
            break
        case YTBroadcastLifeCycleStatus.complete.rawValue:
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "PlayViewController") as! PlayViewController
            self.present(controller, animated: true, completion: nil)
        default:
            break
        }
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let broadcast = broadcasts[indexPath.row]
            self.startAnimating()
            YTLive.shard().liveBroadcastDelete(broadcast.id!, accessToken: self.gi.accessToken, success: { () in
                self.broadcasts.remove(at: indexPath.row)
                tableView.reloadData()
                self.stopAnimating()
            }, failure: {
                self.stopAnimating()
            })

        }
    }
}

class BroadcastTabelCell: UITableViewCell {
    @IBOutlet var baseView: UIView!
    @IBOutlet var ytImageView: UIImageView!
    @IBOutlet var ytNameLabel: UILabel!
    @IBOutlet var ytActivityLabel: UILabel!
    
    override func awakeFromNib() {
        baseView.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.8)
        baseView.layer.borderWidth = 1
        baseView.layer.borderColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        baseView.layer.cornerRadius = 10
    }
}
