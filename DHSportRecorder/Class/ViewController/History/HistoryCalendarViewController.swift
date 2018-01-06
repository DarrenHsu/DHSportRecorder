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
    
    let hourViewHeight: Int = 120
    let temMinuteHight: Int = 20
    let minuteHight: Int = 2
    
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
                v.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
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
    
    @objc func reloadData() {
        DispatchQueue.global(qos: .userInitiated).async {
            for i in 0..<self.dayScrollViews.count {
                let scrollView = self.dayScrollViews[i]
                DispatchQueue.main.async {
                    for v in scrollView.subviews {
                        if v is HistoryView {
                            print("\(v)")
                            v.removeFromSuperview()
                            continue
                        }
                        if v is HistoryRecordView {
                            print("\(v)")
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
                        let s = route.startTime?.transferToString(Date.JSONFormat, format2: "HH")
                        let m = route.startTime?.transferToString(Date.JSONFormat, format2: "mm")
                        let e = route.endTime?.transferToString(Date.JSONFormat, format2: "HH")
                        let y: Int = Int(s!)! - self.history.startHour
                        let s1 = Int(s!)! - self.history.startHour
                        let e1 = Int(e!)! - self.history.startHour
                        let height: Int = e1 - s1 < 1 ? 1 : e1 - s1
                        DispatchQueue.main.async {
                            let rect = CGRect(x: 5,
                                              y: Int(y * self.hourViewHeight + 1) + Int(Int(m!)! / 10 * self.temMinuteHight),
                                              width: Int(scrollView.frame.size.width - 10),
                                              height: Int(height * self.hourViewHeight - 1))
 
                            let historyView: HistoryView = .fromNib()
                            historyView.nameLabel.text = route.name
                            historyView.frame = rect
                            historyView.click = {() in
                                let controller = self.storyboard?.instantiateViewController(withIdentifier: "HistoryDetailViewController") as! HistoryDetailViewController
                                controller.route = route
                                self.navigationController?.pushViewController(controller, animated: true)
                            }
                            scrollView.addSubview(historyView)
                        }
                    }
                }
                
                /* Record */
                if let records = self.history.recordDict[key] {
                    for record in records {
                        let s = record.startTime?.transferToString(Date.JSONFormat, format2: "HH")
                        let sm = record.startTime?.transferToString(Date.JSONFormat, format2: "mm")
                        let e = record.endTime?.transferToString(Date.JSONFormat, format2: "HH")
                        let em = record.endTime?.transferToString(Date.JSONFormat, format2: "mm")
                        let y: Int = Int(s!)! - self.history.startHour
                        let height: Int = (Int(e!)! * self.hourViewHeight + Int(em!)! * self.minuteHight) - (Int(s!)! * self.hourViewHeight + Int(sm!)! * self.minuteHight)
                        DispatchQueue.main.async {
                            let rect = CGRect(x: 5,
                                              y: Int(y * self.hourViewHeight + 1) + Int(sm!)! * self.minuteHight,
                                              width: Int(scrollView.frame.size.width - 10),
                                              height: height < self.temMinuteHight ? self.temMinuteHight : height)
                            
                            let historyView: HistoryRecordView = .fromNib()
                            historyView.nameLabel.text = record.name
                            historyView.frame = rect
                            historyView.click = {() in
                                let controller = self.storyboard?.instantiateViewController(withIdentifier: "HistoryRecordDetailViewController") as! HistoryRecordDetailViewController
                                controller.record = record
                                self.navigationController?.pushViewController(controller, animated: true)
                            }
                            scrollView.addSubview(historyView)
                        }
                    }
                }
            }
        }
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
