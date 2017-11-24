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
        clm.distanceFilter = 10;
        clm.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        clm.startUpdatingLocation()
        if clm.location != nil {
            currentCoordinate = clm.location?.coordinate
            camera = GMSCameraPosition.camera(withTarget: currentCoordinate!, zoom: 18)
        }else {
            camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 18)
        }
        
        mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera!)
        mapView?.isMyLocationEnabled = true
        mapView?.accessibilityElementsHidden = true
        mapView?.delegate = self
        self.view.addSubview(mapView!)
        
        let object = DHLocation.shardDHLocation() as! DHLocation
        object.registerDelegate(self)
        
        icon = UIImage(named: "Header")
        icon = icon?.circleMasked
        path = DHMap.draw(mapView, coordinates: object.coordinates as! [DHLocationCoordinate]!)
        snippet = String(format: "%@ $@", "Tester", "record")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    }
    
    // MARK: - GMSMapViewDelegate Methods
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        self.addMarker()
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        self.addMarker()
    }
    
    // MARK: - DHLocationDelegate Methods
    func receiverStop(_ location: DHLocation!) {
        mapView?.clear()
        self.addMarker()
    }
    
    func receiverChange(_ location: DHLocation!) {
        guard location.currentLocation != nil else {
            return
        }
        
        mapView?.clear()
        
        let coordinate = location.currentLocation.coordinate
        DHMap.add(mapView, path: path as! GMSMutablePath, latitude: coordinate.latitude, longtitude: coordinate.longitude)
        marker = DHMap.draw(mapView, markIcon: icon, title: "Titile", snippet: snippet, latitude: (mapView?.camera.target.latitude)!, longtitude: (mapView?.camera.target.longitude)!)
    }
}
