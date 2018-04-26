//
//  HistoryDetailViewController.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 01/01/2018.
//  Copyright © 2018 D.H. All rights reserved.
//

import UIKit
import Popover
import Firebase

class HistoryDetailViewController: BaseViewController {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var pictureImg: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var routeNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var recordTable: UITableView!
    
    var route: Route?
    var records: [Record]?
    
    var format1: String = "yyyy/MM/dd"
    var format2: String = "HH:mm"
    
    @IBAction func editPressed(_ item: UIBarButtonItem) {
        ui.showActionSheet(self.view, controller: self, title: LString("Message:Item Edit"), actionTitles: [LString("Item:Edit"), LString("Item:Remove"), LString("Item:Cancel")], actions: [
            {(action: UIAlertAction) in
                
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "EditRouteViewController") as! EditRouteViewController
                controller.route = self.route?.copyWithUpdating()
                self.navigationController?.pushViewController(controller, animated: true)
                
            }, {(action: UIAlertAction) in
                
                self.ui.showAlert(LString("Message:Check Remove"), controller: self, submit: {() in
                    self.startAnimating()
                    self.feed.removeRoute((self.route?._id)!, success: { (msg) in
                        self.stopAnimating()
                        self.navigationController?.popViewController(animated: true)
                        NotificationCenter.default.post(name: .needReloadRoute, object: nil)
                    }, failure: { (msg) in
                        self.stopAnimating()
                        self.ui.showAlert(msg, controller: self)
                    })
                    
                }, cancel: nil)
                
            }, {(action: UIAlertAction) in
            }])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Analytics.logEvent(Analytics_History_Route, parameters: [Analytics_User : String(format: "%@", (app.user?._id)!) as Any])
        
        setGeneralStyle(baseView)
        baseView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        
        do {
            var picture = try UIImage(data: Data(contentsOf: URL(fileURLWithPath: self.line.getLocalicturePath())))
            picture = picture?.resizeImage(newWidth: 100)
            picture = picture?.circleMasked
            pictureImg?.image = picture
        }catch {}
        
        nameLabel.text = app.user?.name
        routeNameLabel.text = route?.name
        dateLabel.text = route?.startTime?.transferToString(Date.JSONFormat, format2: format1)
        timeLabel.text = "\(String(describing: (route?.startTime?.transferToString(Date.JSONFormat, format2: format2))!)) ~ \(String(describing: (route?.endTime?.transferToString(Date.JSONFormat, format2: format2))!))"
        
        let key = route?.startTime?.transferToString(Date.JSONFormat, format2: "yyyyMMdd")
        if let rs = history.recordDict[key!] {
            for record in rs {
                let stime = Date.getDateFromString(record.startTime!, format: Date.JSONFormat)
                let etime = Date.getDateFromString(record.endTime!, format: Date.JSONFormat)
                let rstime = Date.getDateFromString((route?.startTime!)!, format: Date.JSONFormat)
                let retime = Date.getDateFromString((route?.endTime!)!, format: Date.JSONFormat)
                if (rstime <= stime &&  etime <= retime) ||
                    (stime >= rstime &&  stime <= retime) ||
                    (etime <= rstime &&  etime >= retime) ||
                    (stime <= rstime &&  rstime <= etime) {
                    if records == nil {
                        records = []
                    }
                    records?.append(record)
                }
            }
        }
        
        setGeneralStyle(recordTable)
        recordTable.isHidden = records == nil || records!.count == 0
    }
}

extension HistoryDetailViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records == nil ? 0 : records!.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! RecordTableCell
        
        let record = records![indexPath.row]
        cell.nameLabel.text = record.name
        cell.localitlyLabel.text = record.locality
        cell.timeLabel.text = "\(String(describing: (record.startTime?.transferToString(Date.JSONFormat, format2: format2))!)) ~ \(String(describing: (record.endTime?.transferToString(Date.JSONFormat, format2: format2))!))"
        cell.distanceLabel.text = String(format: "%.01f", (record.distance)!.doubleValue)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let record = records![indexPath.row]
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "HistoryRecordDetailViewController") as! HistoryRecordDetailViewController
        controller.record = record
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

class RecordTableCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var localitlyLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
}
