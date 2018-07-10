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
    let health = HealthManager.sharedInstance()

    var editingView: UIView!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.endEditing(false)
        
        NVActivityIndicatorView.DEFAULT_TYPE = .lineScale
        NVActivityIndicatorView.DEFAULT_BLOCKER_SIZE = CGSize(width: 100, height: 100)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }

    func setGeneralStyle(_ v: UIView) {
        v.layer.cornerRadius = 15
        v.layer.borderWidth = 1
        v.layer.masksToBounds = true
        v.layer.borderColor = #colorLiteral(red: 0.8320333958, green: 0.8320333958, blue: 0.8320333958, alpha: 1)
    }
    
    // MARK: - KeyboardNotification
    @objc func keyboardWillShow(notification: Notification) {
        guard editingView != nil else { return }
        
        let frame: CGRect = self.view.convert(editingView.frame, from: editingView.superview)
        let eFrame: CGRect = (applicaiton.window?.convert(frame, from: self.view))!
        let sFrame: CGRect = (applicaiton.window?.convert(self.view.frame, from: self.view.superview))!
        let kbFrame = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! CGRect
        
        guard eFrame.origin.y + eFrame.size.height >= kbFrame.origin.y else { return }
        
        let height: CGFloat = CGFloat(-(eFrame.origin.y + eFrame.size.height - kbFrame.origin.y - sFrame.origin.y + 20))
        
        UIView.animate(withDuration: 0.25) {
            self.view.frame = CGRect(x: 0.0, y: height, width: self.view.frame.width, height: self.view.frame.height)
            self.editingView = nil
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.25) {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        }
    }
}
