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

    @IBOutlet var loginSuccessView: UIView?
    @IBOutlet var nextBarItem: UIBarButtonItem?
    
    let signInButton = GIDSignInButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loginSuccessView?.isHidden = true
        
        signInButton.center = view.center
        self.view.addSubview(signInButton)
        
        self.ui.startLoading(self.view)
        gi.authorization(controller: self) { (success) in
            self.ui.stopLoading()
            self.signInButton.isHidden = success
            self.loginSuccessView?.isHidden = !success
            self.nextBarItem?.isEnabled = true
        }
        
        nextBarItem?.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
