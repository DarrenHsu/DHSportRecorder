//
//  ProfileViewController.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 04/12/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit
import LineSDK

class ProfileViewController: BaseViewController {
    
    @IBOutlet weak var photoImageView: UIImageView?
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var gendersSegmented: UISegmentedControl?
    @IBOutlet weak var ageTextField: UITextField?
    @IBOutlet weak var weightTextField: UITextField?
    @IBOutlet weak var heightTextField: UITextField?
    @IBOutlet weak var doneBarItem: UIBarButtonItem?
    @IBOutlet weak var profileView: UIView?
    
    var orignalRect: CGRect?
    
    @IBAction func donePressed() {
        self.view.endEditing(true)
        
        if let user = self.app.setupUser {
            if self.line.profile != nil {
                user.name = self.line.profile?.displayName
                user.lineUserId = self.line.profile?.userID
                user.pictureUrl = "\((self.line.profile?.pictureURL!)!)"
            }
            user.gender = NSNumber(value: (self.gendersSegmented?.selectedSegmentIndex)!)
            user.age = NSNumber(value: Int((self.ageTextField?.text)!)!)
            user.height = NSNumber(value: Int((self.heightTextField?.text)!)!)
            user.weight = NSNumber(value: Int((self.weightTextField?.text)!)!)
            
            self.startAnimating()
            self.feed.addtUser(user, success: {
                self.stopAnimating()
                self.app.user?.save()
                self.applicaiton.goRecordController()
            }, failure: { (msg) in
                self.stopAnimating()
                self.ui.showAlert(msg, controller: self)
            })
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel?.text = self.line.profile?.displayName
        
        self.doneBarItem?.isEnabled = false

        self.startAnimating()
        self.feed.listUser((self.app.setupUser?.lineUserId)!, success: {
            self.stopAnimating()
            self.app.user?.save()
            self.applicaiton.goRecordController()
        }) { (msg) in
            self.stopAnimating()
            self.setDefaultValue()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.orignalRect = self.profileView?.frame
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setDefaultValue() {
        if self.line.profile != nil {
            if let pictureURL: URL = self.line.profile?.pictureURL {
                self.feed.downloadFile(pictureURL, destination: URL(fileURLWithPath: self.line.getLocalicturePath()), success: { () in
                    do {
                        let img = try UIImage(data: Data(contentsOf: URL(fileURLWithPath: self.line.getLocalicturePath())))
                        self.photoImageView?.image = img?.circleMasked
                    }catch {}
                })
            }
        }
        
        if let user = self.app.user {
            if user.name != nil {
                nameLabel?.text = user.name!
            }
            
            if user.gender != nil {
                gendersSegmented?.selectedSegmentIndex = (user.gender?.intValue)!
            }
            
            if user.age != nil {
                ageTextField?.text = "\(String(describing: user.age!))"
            }
            if user.height != nil {
                heightTextField?.text = "\(String(describing: user.height!))"
            }
            
            if user.weight != nil {
                weightTextField?.text = "\(String(describing: user.weight!))"
            }
        }
        
        self.doneBarItem?.isEnabled = true
    }
    
    @objc func keyboardDidHide(notification: Notification) {
        var frame = self.view.frame
        frame.origin.y = 0
        
        UIView.animate(withDuration: 0.28, animations: {
            self.view.frame = frame
        }, completion: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        let userInfo = notification.userInfo
        let krect = (userInfo![UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        
        let pframe = self.profileView?.frame
        
        var frame = self.view.frame
        frame.origin.y = -abs((pframe?.origin.y)! + (pframe?.size.height)! - (krect?.origin.y)!)
        
        UIView.animate(withDuration: 0.28, animations: {
            self.view.frame = frame
        }, completion: nil)
    }
    

}
