//
//  LineBotViewController.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 04/01/2018.
//  Copyright © 2018 D.H. All rights reserved.
//

import UIKit

class LineBotViewController: BaseViewController {
    
    @IBOutlet var baseView: [UIView]!
    @IBOutlet var versionLabel: UILabel!
    
    @IBAction func addPressed(_ sender: UIButton) {
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
