//
//  HistoryDetailViewController.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 01/01/2018.
//  Copyright © 2018 D.H. All rights reserved.
//

import UIKit
import Popover

class HistoryDetailViewController: BaseViewController {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var pictureImg: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var routeNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var route: Route?
    
    var format1: String = "yyyy/MM/dd"
    var format2: String = "HH:ss"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseView.layer.borderColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        baseView.layer.borderWidth = 1
        baseView.layer.cornerRadius = 15
        baseView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        
        do {
            var picture = try UIImage(data: Data(contentsOf: URL(fileURLWithPath: self.line.getLocalicturePath())))
            picture = picture?.resizeImage(newWidth: 100)
            picture = picture?.circleMasked
            pictureImg?.image = picture
        }catch {}
        
        nameLabel.text = app.user?.name
        routeNameLabel.text = route?.name
        dateLabel.text = route?.startTime?.transferToString(Date.JSONFormat, format2: format1)
        timeLabel.text = "\(String(describing: (route?.startTime?.transferToString(Date.JSONFormat, format2: format2))!)) ~ \(String(describing: (route?.endTime?.transferToString(Date.JSONFormat, format2: format2))!))"
    }
}
