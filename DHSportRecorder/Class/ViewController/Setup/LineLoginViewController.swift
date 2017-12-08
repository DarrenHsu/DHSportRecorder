//
//  LineLoginViewController.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 04/12/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit
import LineSDK

class LineLoginViewController: BaseViewController, LineSDKLoginDelegate {
    
    @IBOutlet var lineLoginButton: UIButton?
    @IBOutlet var loginSuccessView: UIView?
    @IBOutlet var nextBarItem: UIBarButtonItem?
    
    @IBAction func lineLoginPressed(sender: UIButton) {
        LineSDKLogin.sharedInstance().start()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        LineSDKLogin.sharedInstance().delegate = self
        
        loginSuccessView?.isHidden = true
        nextBarItem?.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: LineSDKLoginDelegate
    func didLogin(_ login: LineSDKLogin, credential: LineSDKCredential?, profile: LineSDKProfile?, error: Error?) {
        
        if let error = error {
            print("LINE Login Failed with Error: \(error.localizedDescription) ")
            return
        }
        
        guard let profile = profile, let credential = credential, let accessToken = credential.accessToken else {
            print("Invalid Repsonse")
            return
        }
        
        self.line.profile = profile
        
        LogManager.DLog("LINE Login Succeeded")
        LogManager.DLog("Access Token: \(accessToken.accessToken)")
        LogManager.DLog("User ID: \(profile.userID)")
        LogManager.DLog("Display Name: \(profile.displayName)")
        LogManager.DLog("Picture URL: \(profile.pictureURL as URL?)")
        LogManager.DLog("Status Message: \(profile.statusMessage as String?)")
        
        let user = User()
        self.app.user = user
        self.app.user?.name = profile.displayName
        self.app.user?.lineUserId = profile.userID
        self.app.user?.pictureUrl = "\(profile.pictureURL!)"
        
        lineLoginButton?.isHidden = true
        loginSuccessView?.isHidden = false
        nextBarItem?.isEnabled = true
    }

}
