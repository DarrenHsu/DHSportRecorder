//
//  HistoryRecordDetailViewController.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 01/01/2018.
//  Copyright © 2018 D.H. All rights reserved.
//

import UIKit
import GoogleMaps

class HistoryRecordDetailViewController: BaseViewController {
    
    @IBOutlet weak var dataBaseView: UIView!
    @IBOutlet weak var mapBaseView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var localitlyLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var maxSpeedLabel: UILabel!
    @IBOutlet weak var avgSpeedLabel: UILabel!
    
    private var mapView: GMSMapView?
    private var marker: GMSMarker?
    private var camera: GMSCameraPosition?
    private var currentCoordinate: CLLocationCoordinate2D?
    private var currentDirection: CLLocationDirection?
    
    var record: Record?
    
    let format1: String = "yyyy/MM/dd"
    let format2: String = "HH:ss"

    override func viewDidLoad() {
        super.viewDidLoad()

        dataBaseView?.layer.cornerRadius = 15
        dataBaseView?.layer.borderWidth = 1
        dataBaseView?.layer.borderColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        
        mapBaseView?.layer.cornerRadius = 15
        mapBaseView?.layer.borderWidth = 1
        mapBaseView?.layer.masksToBounds = true
        mapBaseView?.layer.borderColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        
        nameLabel.text = record?.name
        localitlyLabel.text = record?.locality
        dateLabel.text = record?.startTime?.transferToString(Date.JSONFormat, format2: format1)
        timeLabel.text = "\(String(describing: (record?.startTime?.transferToString(Date.JSONFormat, format2: format2))!)) ~ \(String(describing: (record?.endTime?.transferToString(Date.JSONFormat, format2: format2))!))"
        distanceLabel.text = String(format: "%.01f", (record?.distance)!.doubleValue)
        maxSpeedLabel.text = String(format: "%.01f", (record?.maxSpeed)!.doubleValue)
        avgSpeedLabel.text = String(format: "%.01f", (record?.avgSpeed)!.doubleValue)
        
        GMSServices.provideAPIKey(GIDSignInManager.sharedInstance().getAPIKey())
        
        let clm = CLLocationManager()
        clm.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        clm.startUpdatingLocation()
        if clm.location != nil {
            currentCoordinate = clm.location?.coordinate
            camera = GMSCameraPosition.camera(withTarget: currentCoordinate!, zoom: 18)
        }else {
            camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 18)
        }
        
        mapView = GMSMapView.map(withFrame: (mapBaseView?.bounds)!, camera: camera!)
        mapView?.isMyLocationEnabled = false
        mapView?.accessibilityElementsHidden = true
        mapView?.alpha = 0
        mapBaseView?.addSubview(mapView!)
        
        DHMap.draw(mapView, coordinates: record?.locations)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.mapView?.frame = (self.mapBaseView?.bounds)!
        UIView.animate(withDuration: 0.3) {
            self.mapView?.alpha = 1
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
