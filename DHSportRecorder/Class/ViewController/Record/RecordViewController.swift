//
//  RecordViewController.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 08/11/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

class RecordViewController: BaseViewController, DHLocationDelegate {
    
    @IBOutlet weak var recordFrame: UIView?
    
    @IBOutlet weak var profileFrame: UIView?
    @IBOutlet weak var pictureImg: UIImageView?
    @IBOutlet weak var nameLabel: UILabel?

    @IBOutlet weak var playButton: UIButton?
    @IBOutlet weak var startLocationImageView: UIImageView?

    @IBOutlet weak var cityLabel: UILabel?
    @IBOutlet weak var reocrdNameLabel: UILabel?
    @IBOutlet weak var distanceLabel: UILabel?
    @IBOutlet weak var currentSpeedLabel: UILabel?
    @IBOutlet weak var elapseedLabel: UILabel?
    @IBOutlet weak var maxSpeedLabel: UILabel?
    @IBOutlet weak var heightLabel: UILabel?
    @IBOutlet weak var avgSpeedLabel: UILabel?
    
    var tmp: Double = 0.0001
    let lat: Double = 25.050143075261012
    let long: Double = 121.55928204761648

    var startDate: Date!
    var saveInterval: Int = 10
    var cacheInterval: Int = 60
    var cacheDistance: Int = 500
    
    @IBAction func startRecordPressed(sender: UIButton) {
        let object = DHLocation.shard()
        if object?.appCurrentActionTag == KATStopRecoding {
            let r = arc4random() % 100
            object?.start(withLocationName: String(format: "record %d", r), locationId: DHLocation.stringWithNewUUID())
        } else if object?.appCurrentActionTag == KATPlayRecoding {
            object?.stop()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        recordFrame?.layer.borderColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        recordFrame?.layer.borderWidth = 1
        recordFrame?.layer.cornerRadius = 15
        recordFrame?.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        
        profileFrame?.layer.borderColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        profileFrame?.layer.borderWidth = 1
        profileFrame?.layer.cornerRadius = 15
        
        DHLocation.shard().registerDelegate(self)
        
        self.setDefaultValue()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
        reocrdNameLabel?.text = object?.locationName
        cityLabel?.text = object?.locality
        
        distanceLabel?.text = String(format: "%.01f", (object?.cumulativeKM)!)
        currentSpeedLabel?.text = String(format: "%.01f", (object?.currentSpeed)!)
        heightLabel?.text = String(format: "%.01f", (object?.altitude)!)
        maxSpeedLabel?.text = String(format: "%.01f", (object?.hightSpeed)!)
        avgSpeedLabel?.text = String(format: "%.01f", (object?.averageSpeed)!)
        startLocationImageView?.image = UIImage(named: (object?.locationOn)! ? "ic_gps_on" : "ic_gps_off")
        
        let intev = object?.cumulativeTimeInternal;
        let cumulativeTime = String(format: "%02d:%02d:%02d", intev! / 3600,(intev! % 3600) / 60 , intev! % 60)
        elapseedLabel?.text = cumulativeTime
        
        if object?.locality != nil {
            self.app.addRecord?.locality = object?.locality
        }
        
        self.app.addRecord?.maxSpeed = NSNumber(value: Double((object?.hightSpeed)!))
        self.app.addRecord?.avgSpeed = NSNumber(value: Double((object?.averageSpeed)!))
        self.app.addRecord?.distance = NSNumber(value: Double((object?.cumulativeKM)!))
        self.app.addRecord?.altitude = NSNumber(value: Double((object?.altitude)!))
        self.app.addRecord?.endTime = Date().toJSONformat()
    }
    
    // MARK: - DHLocationDelegate Methods
    func receiveStart(_ location: DHLocation!) {
        self.syncData()
        
        if let record = RecordAdding.getObject() {
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
        }
    }
    
    func receiveWillStop(_ location: DHLocation!) {
        self.app.addRecord?.endTime = Date().toJSONformat()
        
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
    
    func receiveChangeTime(_ location: DHLocation!) {
        self.syncData()

        let interval: Int = Int(Date().timeIntervalSince(startDate))
        
        if interval % saveInterval == 0 {
            self.app.addRecord?.save()
        }
        
        if interval % cacheInterval != 0 {
            return
        }
        
        if let location = self.app.addRecord?.locations?.last {
            if let index = self.app.addRecord?.imglocations?.last {
                let l: [NSNumber]! = self.app.addRecord?.locations![index]
                let loaA = CLLocation(latitude: CLLocationDegrees(truncating: location[0]), longitude: CLLocationDegrees(truncating: location[1]))
                let loaB = CLLocation(latitude: CLLocationDegrees(truncating: l[0]), longitude: CLLocationDegrees(truncating: l[1]))
                let distance = loaA.distance(from: loaB)
                if Int(distance) >= cacheDistance {
                    self.app.addRecord?.imglocations?.append((self.app.addRecord?.locations?.count)! - 1)
                    LogManager.DLog("add img location")
                }
            }else {
                let l: [NSNumber]! = self.app.addRecord?.locations?.first
                let loaA = CLLocation(latitude: CLLocationDegrees(truncating: location[0]), longitude: CLLocationDegrees(truncating: location[1]))
                let loaB = CLLocation(latitude: CLLocationDegrees(truncating: l[0]), longitude: CLLocationDegrees(truncating: l[1]))
                let distance = loaA.distance(from: loaB)
                if Int(distance) >= cacheDistance {
                    self.app.addRecord?.imglocations?.append((self.app.addRecord?.locations?.count)! - 1)
                    LogManager.DLog("add img location")
                }
            }
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
    }
    
    func receiveError(_ location: DHLocation!) {
        self.syncData()
    }
}
