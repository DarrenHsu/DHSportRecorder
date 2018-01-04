//
//  MapViewController.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 08/11/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: BaseViewController, GMSMapViewDelegate, DHLocationDelegate {

    @IBOutlet weak var mapBaseView: UIView!
    @IBOutlet weak var lockBaseView: UIView!
    @IBOutlet weak var lockSwitch: UISwitch!
    
    private var mapView: GMSMapView?
    private var marker: GMSMarker?
    private var path: GMSPath?
    private var icon: UIImage?
    private var snippet: String?
    private var currentCoordinate: CLLocationCoordinate2D?
    private var currentDirection: CLLocationDirection?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        GMSServices.provideAPIKey(GIDSignInManager.sharedInstance().getAPIKey())
        
        var camera: GMSCameraPosition? = nil
        
        let clm = CLLocationManager()
        clm.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        clm.startUpdatingLocation()
        if clm.location != nil {
            currentCoordinate = clm.location?.coordinate
            camera = GMSCameraPosition.camera(withTarget: currentCoordinate!, zoom: 19)
        }else {
            camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 18)
        }
        
        let object = DHLocation.shard()
        object?.registerDelegate(self)
        
        do {
            icon = try UIImage(data: Data(contentsOf: URL(fileURLWithPath: self.line.getLocalicturePath())))
            icon = icon?.resizeImage(newWidth: 100)
            icon = icon?.circleMasked
        }catch {}

        setGeneralStyle(mapBaseView)
        setGeneralStyle(lockBaseView)
        
        lockSwitch.tintColor = UIColor.black
        lockSwitch.onTintColor = UIColor.black
        
        lockBaseView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        
        mapView = GMSMapView.map(withFrame: mapBaseView.bounds, camera: camera!)
        mapView?.isMyLocationEnabled = true
        mapView?.accessibilityElementsHidden = true
        mapView?.addObserver(self, forKeyPath: "myLocation", options: [.old, .new], context: nil)
        mapBaseView.addSubview(mapView!)
        
        path = DHMap.draw(mapView, coordinates: object?.coordinates as! [Any])
        snippet = String(format: "%@ $@", "Tester", "record")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mapView?.frame = mapBaseView.bounds
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "myLocation" {
            self.addMarker()
        }
    }
    
    func addMarker() {
        if let m = marker {
            if m.map == nil {
                marker?.map = mapView
            }
            
            if mapView?.myLocation != nil {
                DHMap.moveMark(m, latitude: (mapView?.myLocation?.coordinate.latitude)!, longtitude: (mapView?.myLocation?.coordinate.longitude)!)
            }
        }else {
            marker = DHMap.draw(mapView, markIcon: icon, title: "Titile", snippet: snippet, latitude: (mapView?.camera.target.latitude)!, longtitude: (mapView?.camera.target.longitude)!)
        }
        
        if lockSwitch.isOn {
            let camera = GMSCameraPosition.camera(withTarget: (mapView?.myLocation?.coordinate)!, zoom: 19)
            mapView?.moveCamera(GMSCameraUpdate.setCamera(camera))
        }
    }
    
    // MARK: - DHLocationDelegate Methods
    func receiveStop(_ location: DHLocation!) {
        mapView?.clear()
        self.addMarker()
    }
    
    func receiveChange(_ location: DHLocation!) {
        guard location.currentLocation != nil else {
            return
        }
        
        let coordinate = location.currentLocation.coordinate
        DHMap.add(mapView, path: path as! GMSMutablePath, latitude: coordinate.latitude, longtitude: coordinate.longitude)
        self.addMarker()
    }
}
