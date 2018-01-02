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
    let format2: String = "HH:mm"
    
    @IBAction func editPressed(_ item: UIBarButtonItem) {
        ui.showActionSheet(self.view, controller: self, title: LString("Message:Item Edit"), actionTitles: [LString("Item:Remove"), LString("Item:Cancel")], actions: [{(UIAlertAction) in
            self.ui.showAlert(LString("Message:Check Remove"), controller: self, submit: {() in
                
                self.startAnimating()
                self.feed.removeRecord((self.record?._id)!, success: { (msg) in
                    self.stopAnimating()
                    self.dismiss(animated: true, completion: nil)
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
        
        loadRecordImage()
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
    
    func loadRecordImage() {
        if record?.locations?.first != nil {
            do {
                var icon = try UIImage(data: Data(contentsOf: URL(fileURLWithPath: self.line.getLocalicturePath())))
                icon = icon?.resizeImage(newWidth: 50)
                icon = icon?.circleMasked
                
                var location: [NSNumber]! = record?.locations!.last
                var lat: CLLocationDegrees = CLLocationDegrees(truncating: location[0])
                var lon: CLLocationDegrees = CLLocationDegrees(truncating: location[1])
                DHMap.draw(self.mapView, markIcon: icon, title: "", snippet: "", latitude: lat, longtitude: lon)
                
                icon = icon?.alpha(0.4)
                location = record?.locations!.first
                lat = CLLocationDegrees(truncating: location[0])
                lon = CLLocationDegrees(truncating: location[1])
                DHMap.draw(self.mapView, markIcon: icon, title: "", snippet: "", latitude: lat, longtitude: lon)
            }catch {}
        }

        for index in (record?.imglocations)! {
            let location: [NSNumber]! = record?.locations![index]
            let lat: CLLocationDegrees = CLLocationDegrees(truncating: location[0])
            let lon: CLLocationDegrees = CLLocationDegrees(truncating: location[1])
            feed.loadGoogleMapImage(lat, lon: lon, width: 160, height: 240, success: { (image) in
                DHMap.draw(self.mapView, markIcon: image, title: "", snippet: "", latitude: lat, longtitude: lon)
            })
        }
    }
    
}
