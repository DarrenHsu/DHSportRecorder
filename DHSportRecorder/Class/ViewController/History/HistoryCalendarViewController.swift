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
    @IBOutlet var dayLabel: [UILabel]!
    @IBOutlet var dayView: [UIView]!
    
    let minuteHight: Int = 1
    let hourViewHeight: Int = 60
    let temMinuteHight: Int =  10
    
    var index: Int = 0
    var today: Date = Date()
    var weekDay: Int!
    
    var isReload = true
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        ui.removeObserver(self, forKeyPath: "contentOffSet")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weekDay = today.weekDay()
        
        for i in 0..<dayLabel.count {
            let view = dayView[i]
            let label = dayLabel[i]
            
            if (today.year() == history.currentDate.year() && today.month() == history.currentDate.month() && today.day() == history.currentDate.day()) && i == weekDay {
                view.backgroundColor = UIColor.red
                view.layer.cornerRadius = view.frame.size.width / 2
                view.clipsToBounds = true
                view.isHidden = false
                label.textColor = UIColor.white
            }else {
                view.isHidden = true
                label.textColor = UIColor.darkGray
            }
            
            if i == weekDay {
                label.text = String(format: "%d", today.day())
            }else if i < weekDay {
                label.text = String(format: "%d", today.increaseDay(day: -(weekDay - i)).day())
            }else if i > weekDay {
                label.text = String(format: "%d", today.increaseDay(day: i - weekDay).day())
            }
        }

        for scrollView in dayScrollViews {
            scrollView.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.7)
            scrollView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1).cgColor
            scrollView.layer.borderWidth = 0.5
            
            var y: CGFloat = 0
            for _ in 0..<(history.endHour - history.startHour) {
                y += CGFloat(hourViewHeight)
                let v = UIView(frame: CGRect(x: 2, y: y, width: scrollView.frame.size.width - 4, height: 1))
                v.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
                scrollView.addSubview(v)
            }
            scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: y)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .loadHistoryFinished, object: nil)
        ui.addObserver(self, forKeyPath: "contentOffSet" , options: [.new, .old], context: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isReload {
            reloadData()
            isReload = false
        }
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
    
    @objc func reloadData() {
        DispatchQueue.global(qos: .userInitiated).async {
            for i in 0..<self.dayScrollViews.count {
                let scrollView = self.dayScrollViews[i]
                DispatchQueue.main.async {
                    for v in scrollView.subviews {
                        if v is HistoryView || v is HistoryRecordView {
                            v.removeFromSuperview()
                            continue
                        }
                    }
                    
                    scrollView.contentOffset = self.ui.contentOffSet
                }
                
                var date: Date
                if i < self.weekDay {
                    date = self.today.increaseDay(day: -(self.weekDay - i))
                } else if i > self.weekDay {
                    date = self.today.increaseDay(day: i - self.weekDay)
                } else {
                    date = self.today
                }
                
                /* Route */
                let key = date.stringDate("yyyyMMdd")
                if let routes = self.history.routeDict[key] {
                    for route in routes {
                        DispatchQueue.main.async {
                            let rect = self.getRect(route.startTime!, endTime: route.endTime!, width: scrollView.frame.size.width)
                            let historyView: HistoryView = .fromNib()
                            historyView.nameLabel.text = route.name
                            historyView.frame = rect
                            historyView.click = { [weak self]() in
                                let controller = self?.storyboard?.instantiateViewController(withIdentifier: "HistoryDetailViewController") as! HistoryDetailViewController
                                controller.route = route
                                self?.navigationController?.pushViewController(controller, animated: true)
                            }
                            scrollView.addSubview(historyView)
                        }
                    }
                }
                
                /* Record */
                if let records = self.history.recordDict[key] {
                    for record in records {
                        DispatchQueue.main.async {
                            let rect = self.getRect(record.startTime!, endTime: record.endTime!, width: scrollView.frame.size.width)
                            let historyView: HistoryRecordView = .fromNib()
                            historyView.frame = rect
                            historyView.click = { [weak self]() in
                                let controller = self?.storyboard?.instantiateViewController(withIdentifier: "HistoryRecordDetailViewController") as! HistoryRecordDetailViewController
                                controller.record = record
                                self?.navigationController?.pushViewController(controller, animated: true)
                            }
                            scrollView.addSubview(historyView)
                        }
                    }
                }
            }
        }
    }
    
    func getRect(_ startTime: String, endTime: String, width: CGFloat) -> CGRect {
        let s = startTime.transferToString(Date.JSONFormat, format2: "HH")
        let sm = startTime.transferToString(Date.JSONFormat, format2: "mm")
        let e = endTime.transferToString(Date.JSONFormat, format2: "HH")
        let em = endTime.transferToString(Date.JSONFormat, format2: "mm")
        let y: Int = (Int(s)! - self.history.startHour) * 60 + Int(sm)!
        let s1 = (Int(s)! - self.history.startHour) * 60 + Int(sm)!
        let e1 = (Int(e)! - self.history.startHour) * 60 + Int(em)!
        let height: Int = e1 - s1 < 10 ? 10 : e1 - s1
        return CGRect(x: 5,
                          y: y * self.minuteHight,
                          width: Int(width - 10),
                          height: height * self.minuteHight)
    }
    
    // MARK: - UIScrollViewDelegate Methods
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        ui.contentOffSet = scrollView.contentOffset
        
        if scrollView.contentOffset.y < -120 {
            NotificationCenter.default.post(name: .needReloadRoute, object: nil)
            return
        }
        
        for sview in dayScrollViews {
            if sview == scrollView {
                continue
            }
            sview.contentOffset = scrollView.contentOffset
        }
    }

}
