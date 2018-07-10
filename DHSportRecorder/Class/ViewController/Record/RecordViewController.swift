//
//  RecordViewController.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 08/11/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit
import Firebase

class RecordViewController: BaseViewController {
    
    @IBOutlet weak var recordFrame: UIView!
    @IBOutlet weak var baseImageView: UIImageView!
    @IBOutlet weak var profileFrame: UIView!
    @IBOutlet weak var pictureImg: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var startLocationImageView: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var reocrdNameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var currentSpeedLabel: UILabel!
    @IBOutlet weak var elapseedLabel: UILabel!
    @IBOutlet weak var maxSpeedLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var avgSpeedLabel: UILabel!
    
    var tmp: Double = 0.0001
    let lat: Double = 25.050143075261012
    let long: Double = 121.55928204761648

    var startDate: Date!
    var saveInterval: Int = 5
    var imgTempDistance: Float = 0
    var pushTempDistance: Float = 0
    var step: Double = 0
    
    @IBAction func startRecordPressed(sender: UIButton) {
        let object = DHLocation.shard()
        if object?.appCurrentActionTag == KATStopRecoding {
            let r = arc4random() % 100
            object?.start(withLocationName: String(format: "record %d", r), locationId: DHLocation.stringWithNewUUID())
            
            Analytics.logEvent(Analytics_Recorder_Start, parameters: [Analytics_User : String(format: "%@", (app.user?._id)!) as Any])
        } else if object?.appCurrentActionTag == KATPlayRecoding {
            object?.stop()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileFrame.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        recordFrame.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        
        baseImageView.image = UIImageEffects.imageByApplyingDarkEffect(to: baseImageView.image)
        
        DHLocation.shard().registerDelegate(self)
        
        self.setDefaultValue()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Analytics.logEvent(Analytics_Recorder, parameters: [Analytics_User : String(format: "%@", (app.user?._id)!) as Any])
    }

    func setDefaultValue() {
        do {
            var picture = try UIImage(data: Data(contentsOf: URL(fileURLWithPath: self.line.getLocalicturePath())))
            picture = picture?.resizeImage(newWidth: 100)
            picture = picture?.circleMasked
            pictureImg?.image = picture
        }catch {}
        
        nameLabel?.text = self.app.user?.name
    }
    
    func syncData() {
        let object = DHLocation.shard()
        
        if object?.appCurrentActionTag == KATPlayRecoding {
            playButton?.setImage(UIImage(named: "ic_record_on"), for: UIControlState.normal)
        } else if object?.appCurrentActionTag == KATStopRecoding {
            playButton?.setImage(UIImage(named: "ic_record_off"), for: UIControlState.normal)
        }
    
        reocrdNameLabel.text = object?.locationName
        cityLabel.text = object?.locality
        
        distanceLabel.text = String(format: "%.01f", (object?.cumulativeKM)!)
        currentSpeedLabel.text = String(format: "%.01f", (object?.currentSpeed)!)
        heightLabel.text = String(format: "%.01f", (object?.altitude)!)
        maxSpeedLabel.text = String(format: "%.01f", (object?.hightSpeed)!)
        avgSpeedLabel.text = String(format: "%.01f", (object?.averageSpeed)!)
        startLocationImageView.image = UIImage(named: (object?.locationOn)! ? "ic_gps_on" : "ic_gps_off")
        
        let intev = object?.cumulativeTimeInternal;
        let cumulativeTime = String(format: "%02d:%02d:%02d", intev! / 3600,(intev! % 3600) / 60 , intev! % 60)
        elapseedLabel.text = cumulativeTime
        
        if object?.locality != nil {
            self.app.addRecord?.locality = object?.locality
        }
        
        self.app.addRecord?.maxSpeed = NSNumber(value: Double((object?.hightSpeed)!))
        self.app.addRecord?.avgSpeed = NSNumber(value: Double((object?.averageSpeed)!))
        self.app.addRecord?.distance = NSNumber(value: Double((object?.cumulativeKM)!))
        self.app.addRecord?.altitude = NSNumber(value: Double((object?.altitude)!))
        self.app.addRecord?.endTime = Date().toJSONformat()
    }
    
    func saveRecord() {
        DispatchQueue.main.async {
            self.startAnimating()
            FeedManager.sharedInstance().addtRecord(self.app.addRecord!, success: { (r) in
                self.stopAnimating()
                self.app.addRecord?.save()
                self.app.addRecord?.removeSource()
                NotificationCenter.default.post(name: .needReloadRoute, object: nil)
            }) { (msg) in
                self.stopAnimating()
                self.ui.showAlert(msg, controller: self)
            }
        }
    }
}

extension RecordViewController: DHLocationDelegate {
    func receiveStart(_ location: DHLocation!) {
        self.syncData()
        
        guard let record = RecordAdding.getObject() else { return; }
        
        self.app.addRecord = record
        
        if record.recordId == nil {
            LogManager.DLog("record not exist")
            self.app.addRecord?.recordId = location.locationID
            self.app.addRecord?.name = location.locationName
            self.app.addRecord?.lineUserId = self.app.user?.lineUserId
            
            if self.app.addRecord?.imglocations == nil {
                self.app.addRecord?.locations = []
            }
            self.app.addRecord?.locations?.removeAll()
            
            if self.app.addRecord?.imglocations == nil {
                self.app.addRecord?.imglocations = []
            }
            self.app.addRecord?.imglocations?.removeAll()
            
            startDate = Date()
            self.app.addRecord?.startTime = startDate.toJSONformat()
        }else {
            LogManager.DLog("record exist")
            location.locationName = record.name
            location.locationID = record.recordId
            location.locality = record.locality
            if let distance = record.distance {
                location.cumulativeKM = distance.floatValue
            }
            if let maxSpeed = record.maxSpeed {
                location.hightSpeed = maxSpeed.floatValue
            }
            if let avgSpeed = record.avgSpeed {
                location.averageSpeed = avgSpeed.floatValue
            }
            if let altitude = record.altitude {
                location.altitude = altitude.doubleValue
            }
            
            let sdate = Date.getDateFromString(record.startTime!, format: Date.JSONFormat)
            let edate = Date.getDateFromString(record.endTime!, format: Date.JSONFormat)
            location.cumulativeMS = edate.timeIntervalSince(sdate)
            location.cumulativeTimeInternal = UInt32(edate.timeIntervalSince(sdate))
            
            startDate = sdate
            
            for loa in record.locations! {
                let coordinate = DHLocationCoordinate()
                coordinate.latitude = CLLocationDegrees(truncating: loa[0])
                coordinate.longitude = CLLocationDegrees(truncating: loa[1])
                location.coordinates.add(coordinate)
            }
        }
        
        health.requestHealthAvaliable { [weak self] (success) in
            guard success else { return }
            
            self?.health.getTodaysSteps { (step) in
                self?.step = step
            }
        }
        
        feed.pushMessage((app.user?.lineUserId)!, message: String(format: LString("LINE:StarMoving"), (app.user?.name)!))
    }
    
    func receiveWillStop(_ location: DHLocation!) {
        self.app.addRecord?.endTime = Date().toJSONformat()
        
        feed.pushMessage((app.user?.lineUserId)!, message: String(format: LString("LINE:StopMoving"), (app.user?.name)!, (self.app.addRecord?.distance)!.doubleValue))
        
        health.requestHealthAvaliable { [weak self] (success) in
            guard success else {
                self?.saveRecord()
                return
            }
            
            self?.health.getTodaysSteps { (step) in
                self?.app.addRecord?.step = NSNumber(value: (step - (self?.step)!))
                self?.saveRecord()
            }
        }
    }
    
    func receiveChangeTime(_ location: DHLocation!) {
        self.syncData()
        
        let interval = Int(Date().timeIntervalSince(startDate))
        
        if interval % saveInterval == 0 {
            self.app.addRecord?.save()
        }
    }
    
    func receiveStop(_ location: DHLocation!) {
        self.syncData()
    }
    
    func receiveChange(_ location: DHLocation!) {
        self.syncData()
        
        if location.currentLocation != nil {
            self.app.addRecord?.locations?.append([
                NSNumber(value: location.currentLocation.coordinate.latitude),
                NSNumber(value: location.currentLocation.coordinate.longitude)
                ])
        }
        
        /* save image distance */
        if location.cumulativeKM - imgTempDistance >= app.imgDistance {
            if (self.app.addRecord?.locations?.last) != nil {
                self.app.addRecord?.imglocations?.append((self.app.addRecord?.locations?.count)! - 1)
            }
            
            imgTempDistance = location.cumulativeKM
        }
        
        /* push line message distance */
        if location.cumulativeKM - pushTempDistance >= app.pushDistance {
            feed.pushMessage((app.user?.lineUserId)!, message: String(format: LString("LINE:Moving"), (app.user?.name)!, (self.app.addRecord?.distance)!.doubleValue))
            pushTempDistance = location.cumulativeKM
        }
    }
    
    func receiveError(_ location: DHLocation!) {
        self.syncData()
    }
}
