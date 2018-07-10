//
//  LineLoginViewController.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 04/12/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit
import LineSDK
import Firebase

class LineLoginViewController: BaseViewController, LineSDKLoginDelegate {
    
    @IBOutlet weak var lineLoginButton: UIButton?
    @IBOutlet weak var loginSuccessView: UIView?
    @IBOutlet weak var nextBarItem: UIBarButtonItem?
    
    @IBAction func lineLoginPressed(sender: UIButton) {
        LineSDKLogin.sharedInstance().start()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Analytics.logEvent(Analytics_Setup_Line, parameters: [:])

        LineSDKLogin.sharedInstance().delegate = self
        
        loginSuccessView?.isHidden = true
        nextBarItem?.isEnabled = false
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
        
        let user = UserAdding()
        self.app.setupUser = user
        self.app.setupUser?.name = profile.displayName
        self.app.setupUser?.lineUserId = profile.userID
        self.app.setupUser?.pictureUrl = "\(profile.pictureURL!)"
        
        lineLoginButton?.isHidden = true
        loginSuccessView?.isHidden = false
        nextBarItem?.isEnabled = true
    }

}
