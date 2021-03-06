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
    
    var click: (()->Void)?
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = true
    }
    
    @IBAction func buttonPressed() {
        click?()
    }
}

extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}
