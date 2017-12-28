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
        
        self.app.record?.locality = object?.locality
        self.app.record?.maxSpeed = NSNumber(value: (object?.hightSpeed)!)
        self.app.record?.avgSpeed = NSNumber(value: (object?.averageSpeed)!)
        self.app.record?.distance = NSNumber(value: (object?.cumulativeKM)!)
    }
    
    // MARK: - DHLocationDelegate Methods
    func receiveStart(_ location: DHLocation!) {
        self.syncData()
        
        if let record = Record.getObject() {
            self.app.record = record
            self.app.record?.name = location.locationName
            self.app.record?.lineUserId = self.app.user?.lineUserId
            
            if self.app.record?.imglocations == nil {
                self.app.record?.locations = []
            }
            self.app.record?.locations?.removeAll()
            
            if self.app.record?.imglocations == nil {
                self.app.record?.imglocations = []
            }
            self.app.record?.imglocations?.removeAll()
            
            self.app.record?.startTime = Date().toJSONformat()
        }
    }
    
    func receiveWillStop(_ location: DHLocation!) {
        self.app.record?.endTime = Date().toJSONformat()
        self.app.record?.save()
        self.app.record?.removeSource()
    }
    
    func receiveStop(_ location: DHLocation!) {
        self.syncData()
    }
    
    func receiveChangeTime(_ location: DHLocation!) {
        self.syncData()
    }
    
    func receiveChange(_ location: DHLocation!) {
        self.syncData()
        
        if location.currentLocation != nil {
            self.app.record?.locations?.append([NSNumber(value: location.currentLocation.coordinate.latitude),
                                                NSNumber(value: location.currentLocation.coordinate.longitude)])
        }
    }
    
    func receiveError(_ location: DHLocation!) {
        self.syncData()
    }
    
    
}
