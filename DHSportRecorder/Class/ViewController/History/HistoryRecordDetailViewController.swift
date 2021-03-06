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
    @IBOutlet weak var kcalLabel: UILabel!
    @IBOutlet weak var stepLabel: UILabel!
    
    private var mapView: GMSMapView?
    private var marker: GMSMarker?
    private var camera: GMSCameraPosition?
    private var currentCoordinate: CLLocationCoordinate2D?
    private var currentDirection: CLLocationDirection?
    
    var record: Record?
    
    let format1: String = "yyyy/MM/dd"
    let format2: String = "HH:mm"
    
    @IBAction func editPressed(_ item: UIBarButtonItem) {
        ui.showActionSheet(self.view, controller: self, title: LString("Message:Item Edit"), actionTitles: [LString("Item:PushMessage"), LString("Item:Remove"), LString("Item:Cancel")], actions: [
            {(action: UIAlertAction) in
                self.startAnimating()
                self.feed.pushRecord((self.record?.recordId)!, success: { (msg) in
                    self.stopAnimating()
                    self.ui.showAlert(msg, controller: self)
                }, failure: { (msg) in
                    self.stopAnimating()
                    self.ui.showAlert(msg, controller: self)
                })
            },
            {(UIAlertAction) in
                self.ui.showAlert(LString("Message:Check Remove"), controller: self, submit: {() in
                    
                    self.startAnimating()
                    self.feed.removeRecord((self.record?._id)!, success: { (msg) in
                        self.stopAnimating()
                        self.navigationController?.popToRootViewController(animated: true)
                        NotificationCenter.default.post(name: .needReloadRoute, object: nil)
                    }, failure: { (msg) in
                        self.stopAnimating()
                        self.ui.showAlert(msg, controller: self)
                    })
                }, cancel: nil)
            },
            {(action: UIAlertAction) in
            }])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        GMSServices.provideAPIKey(GIDSignInManager.sharedInstance().getAPIKey())
        
        setGeneralStyle(dataBaseView)
        setGeneralStyle(mapBaseView)
        
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
        
        nameLabel.text = record?.name
        localitlyLabel.text = record?.locality
        dateLabel.text = record?.startTime?.transferToString(Date.JSONFormat, format2: format1)
        timeLabel.text = "\(String(describing: (record?.startTime?.transferToString(Date.JSONFormat, format2: format2))!)) ~ \(String(describing: (record?.endTime?.transferToString(Date.JSONFormat, format2: format2))!))"
        distanceLabel.text = String(format: "%.01f", (record?.distance)!.doubleValue)
        maxSpeedLabel.text = String(format: "%.01f", (record?.maxSpeed)!.doubleValue)
        avgSpeedLabel.text = String(format: "%.01f", (record?.avgSpeed)!.doubleValue)
        kcalLabel.text = String(format: "%d",Int(CaloriesHelpers.getCalories(speed: (record?.avgSpeed?.doubleValue)!, weight: (self.app.user?.weight?.doubleValue)!, minutes: Double((record?.getTotalMinutes())!))))
        stepLabel.text = String(format: "%d", record?.step != nil ? (record?.step?.intValue)! : 0)
        
        DHMap.draw(mapView, coordinates: record?.getDHLocationCoordinates())
        
        loadRecordImage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.mapView?.frame = (self.mapBaseView?.bounds)!
        UIView.animate(withDuration: 0.3) {
            self.mapView?.alpha = 1
        }
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
