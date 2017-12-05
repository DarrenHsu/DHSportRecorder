//
//  ProfileViewController.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 04/12/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

class ProfileViewController: BaseViewController {
    
    @IBOutlet var photoImageView: UIImageView?
    @IBOutlet var nameLabel: UILabel?
    @IBOutlet var gendersSegmented: UISegmentedControl?
    @IBOutlet var ageTextField: UITextField?
    @IBOutlet var weightTextField: UITextField?
    @IBOutlet var heightTextField: UITextField?
    
    @IBAction func donePressed() {
        self.app.goRecordController()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let pictureURL: URL = self.line.profile.pictureURL {
            let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let path = "\(directory)/picture"
            self.feed.downloadFile(pictureURL, destination: URL(string: path)!, success: { (image) in
                self.photoImageView?.image = image
            })
        }
        
        nameLabel?.text = self.line.profile.displayName
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
