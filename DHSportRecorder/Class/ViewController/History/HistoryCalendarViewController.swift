//
//  HistoryCalendarViewController.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 23/12/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

class HistoryCalendarViewController: BaseViewController, UIScrollViewDelegate {
    
    @IBOutlet var dayScrollViews: [UIScrollView]!
    
    var scrollContentOffSet: ((CGPoint)->Void)?
    
    deinit {
        ui.removeObserver(self, forKeyPath: "contentOffSet")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for scrollView in dayScrollViews {
            scrollView.layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1).cgColor
            scrollView.layer.borderWidth = 1
            
            var y: CGFloat = 0
            for _ in 0...23 {
                y += 80
                let v = UIView(frame: CGRect(x: 2, y: y, width: scrollView.frame.size.width - 4, height: 1))
                v.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
                scrollView.addSubview(v)
            }
            scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: y)
            scrollView.contentOffset = ui.contentOffSet
        }
        
        ui.addObserver(self, forKeyPath: "contentOffSet" , options: [.new, .old], context: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffSet" {
            for scrollView in dayScrollViews {
                scrollView.contentOffset = ui.contentOffSet
            }
        }
    }
    
    // MARK: - UIScrollViewDelegate Methods
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        ui.contentOffSet = scrollView.contentOffset
        for sview in dayScrollViews {
            if sview == scrollView {
                continue
            }
            sview.contentOffset = scrollView.contentOffset
        }
    }

}
