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
    
    @IBOutlet var photoImageView: UIImageView?
    @IBOutlet var nameLabel: UILabel?
    @IBOutlet var gendersSegmented: UISegmentedControl?
    @IBOutlet var ageTextField: UITextField?
    @IBOutlet var weightTextField: UITextField?
    @IBOutlet var heightTextField: UITextField?
    @IBOutlet var doneBarItem: UIBarButtonItem?
    @IBOutlet var profileView: UIView?
    
    var orignalRect: CGRect?
    
    @IBAction func donePressed() {
        self.applicaiton.goRecordController()
        
        if let user = self.app.user {
            if self.line.profile != nil {
                user.name = self.line.profile?.displayName
                user.lineUserId = self.line.profile?.userID
                user.pictureUrl = "\((self.line.profile?.pictureURL!)!)"
            }
            user.gender = NSNumber(value: (self.gendersSegmented?.selectedSegmentIndex)!)
            user.age = NSNumber(value: Int((self.ageTextField?.text)!)!)
            user.height = NSNumber(value: Int((self.heightTextField?.text)!)!)
            user.weight = NSNumber(value: Int((self.weightTextField?.text)!)!)
            user.save()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
        
        nameLabel?.text = self.line.profile?.displayName

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        setDefaultValue()
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
