//
//  GoogleLoginViewController.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 04/12/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit
import GoogleSignIn

class GoogleLoginViewController: BaseViewController, GIDSignInUIDelegate {

    @IBOutlet weak var loginSuccessView: UIView?
    @IBOutlet weak var nextBarItem: UIBarButtonItem?
    
    let signInButton = GIDSignInButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loginSuccessView?.isHidden = true
        
        signInButton.center = view.center
        self.view.addSubview(signInButton)
        
        gi.signOut()
        
        self.startAnimating()
        gi.authorization(controller: self) { (success) in
            self.stopAnimating()
            self.signInButton.isHidden = success
            self.loginSuccessView?.isHidden = !success
            self.nextBarItem?.isEnabled = true
            
            if success {
                if let user = self.app.setupUser {
                    user.gmail = self.gi.email
                    user.gAccessToken = self.gi.accessToken
                }
            }
        }
        
        nextBarItem?.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
