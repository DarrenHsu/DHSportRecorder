//
//  OtherViewController.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 08/11/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit
import Firebase

class OtherViewController: BaseViewController {

    @IBOutlet var baseView: [UIView]!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var botImageView: UIImageView!
    @IBOutlet weak var imgDistanceLabel: UILabel!
    @IBOutlet weak var pushDistanceLabel: UILabel!
    
    @IBAction func pushDistancePressed(_ sender: UIButton) {
        let index  = app.distancelist.index(of: String(format:"%.01f" ,app.pushDistance))
        PickerView.presentPicker(sender, defaultIndex: index, dataList: app.distancelist, popoverType: .down) { (d, index) in
            self.pushDistanceLabel.text = d
            self.app.pushDistance = Float(d)!
        }
    }
    
    @IBAction func imgDistancePressed(_ sender: UIButton) {
        let index  = app.distancelist.index(of: String(format:"%.01f" ,app.imgDistance))
        PickerView.presentPicker(sender, defaultIndex: index, dataList: app.distancelist, popoverType: .down) { (d, index) in
            self.imgDistanceLabel.text = d
            self.app.imgDistance = Float(d)!
        }
    }
    
    @IBAction func addPressed(_ sender: UIButton) {
        Analytics.logEvent(Analytics_Other_Friend_Add, parameters: [Analytics_User : String(format: "%@", (app.user?._id)!) as Any])
        
        guard let url = URL(string: LineManager.LINE_BOT_URL) else {
            return
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for bview in baseView {
            setGeneralStyle(bview)
        }
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = version
        }
        
        var image = UIImage(named: "ic_health")
        image = image?.resizeImage(newWidth: botImageView.frame.size.width)
        botImageView.image = image?.circleMasked
        
        imgDistanceLabel.text = String(format: "%.01f", app.imgDistance)
        pushDistanceLabel.text = String(format: "%.01f", app.pushDistance)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Analytics.logEvent(Analytics_Other, parameters: [Analytics_User : String(format: "%@", (app.user?._id)!) as Any])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
