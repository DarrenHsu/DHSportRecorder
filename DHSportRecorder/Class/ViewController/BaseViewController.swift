//
//  BaseViewController.swift
//  DHYoutube
//
//  Created by Darren Hsu on 17/10/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    let applicaiton = UIApplication.shared.delegate as! AppDelegate
    let ui = UIManager.sharedInstance()
    let gi = GIDSignInManager.sharedInstance()
    let feed = FeedManager.sharedInstance()
    let line = LineManager.sharedInstance()
    let app = AppManager.sharedInstance()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
