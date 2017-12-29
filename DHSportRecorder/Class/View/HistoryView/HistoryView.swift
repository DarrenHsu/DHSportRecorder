//
//  HistoryView.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 29/12/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

class HistoryView: UIView {

    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        nameLabel.layer.borderColor = UIColor(hue: 0.8, saturation: 0.8, brightness: 0.0, alpha: 0.5).cgColor
        nameLabel.layer.borderWidth = 1
    }

}

extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}
