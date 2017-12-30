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
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.darkGray.cgColor
        self.layer.borderWidth = 2
    }
}

extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}
