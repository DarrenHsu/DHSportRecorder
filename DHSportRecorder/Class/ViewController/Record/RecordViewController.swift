//
//  RecordViewController.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 08/11/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

class RecordViewController: BaseViewController, DHLocationDelegate {
    
    @IBOutlet var recordFrame: UIView?
    
    @IBOutlet var profileFrame: UIView?
    @IBOutlet var pictureImg: UIImageView?
    @IBOutlet var nameLabel: UILabel?

    @IBOutlet var playButton: UIButton?
    @IBOutlet var startLocationImageView: UIImageView?

    @IBOutlet var cityLabel: UILabel?
    @IBOutlet var reocrdNameLabel: UILabel?
    @IBOutlet var distanceLabel: UILabel?
    @IBOutlet var currentSpeedLabel: UILabel?
    @IBOutlet var elapseedLabel: UILabel?
    @IBOutlet var maxSpeedLabel: UILabel?
    @IBOutlet var heightLabel: UILabel?
    @IBOutlet var avgSpeedLabel: UILabel?
    
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
        
        profileFrame?.layer.borderColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        profileFrame?.layer.borderWidth = 1
        profileFrame?.layer.cornerRadius = 15
        
        do {
            var picture = try UIImage(data: Data(contentsOf: URL(fileURLWithPath: self.line.getLocalicturePath())))
            picture = picture?.resizeImage(newWidth: 100)
            picture = picture?.circleMasked
            pictureImg?.image = picture
        }catch {}
        
        nameLabel?.text = self.app.user?.name
        
        DHLocation.shard().registerDelegate(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    }
    
    //MARK: - DHLocationDelegate Methods
    func receiverStart(_ location: DHLocation!) {
        self.syncData()
    }
    
    func receiverStop(_ location: DHLocation!) {
        self.syncData()
    }
    
    func receiverSuspended(_ location: DHLocation!) {
        self.syncData()
    }
    
    func receiverChangeTime(_ location: DHLocation!) {
        self.syncData()
    }
    
    func receiverChange(_ location: DHLocation!) {
        self.syncData()
    }
    
    func receiverError(_ location: DHLocation!) {
        self.syncData()
    }
    
    
}
