//
//  BaseViewController.swift
//  DHYoutube
//
//  Created by Darren Hsu on 17/10/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class BaseViewController: UIViewController, NVActivityIndicatorViewable {
    
    let applicaiton = UIApplication.shared.delegate as! AppDelegate
    let ui = UIManager.sharedInstance()
    let gi = GIDSignInManager.sharedInstance()
    let feed = FeedManager.sharedInstance()
    let line = LineManager.sharedInstance()
    let app = AppManager.sharedInstance()
    let history = HistoryManager.sharedInstance()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NVActivityIndicatorView.DEFAULT_TYPE = .ballPulse
        NVActivityIndicatorView.DEFAULT_BLOCKER_SIZE = CGSize(width: 100, height: 100)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setGeneralStyle(_ v: UIView) {
        v.layer.cornerRadius = 15
        v.layer.borderWidth = 1
        v.layer.masksToBounds = true
        v.layer.borderColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
    }
    
}
