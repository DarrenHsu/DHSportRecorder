//
//  RecordViewController.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 08/11/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

class RecordViewController: BaseViewController {
    
    @IBOutlet var recordFrame: UIView?
    
    @IBOutlet var profileFrame: UIView?
    @IBOutlet var pictureImg: UIImageView?
    @IBOutlet var nameLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        recordFrame?.layer.borderColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        recordFrame?.layer.borderWidth = 1
        recordFrame?.layer.cornerRadius = 15
        
        profileFrame?.layer.borderColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        profileFrame?.layer.borderWidth = 1
        profileFrame?.layer.cornerRadius = 15
        
        do {
            var picture = try UIImage(data: Data(contentsOf: URL(fileURLWithPath: self.line.getLocalicturePath())))
            picture = picture?.resizeImage(newWidth: 100)
            picture = picture?.circleMasked
            pictureImg?.image = picture
        }catch {}
        
        nameLabel?.text = self.line.profile.displayName
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
