//
//  HistoryViewController.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 08/11/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

class HistoryViewController: BaseViewController {
    
    @IBOutlet weak var timeTable: UITableView!
    @IBOutlet weak var yearMonthLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        ui.addObserver(self, forKeyPath: "contentOffSet" , options: [.new, .old], context: nil)
        history.addObserver(self, forKeyPath: "dynamicDate", options: [.new, .old], context: nil)
    }
    
    deinit {
        ui.removeObserver(self, forKeyPath: "contentOffSet")
        history.removeObserver(self, forKeyPath: "dynamicDate")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .needReloadRoute, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffSet" {
            timeTable.contentOffset = ui.contentOffSet
        }else if keyPath == "dynamicDate" {
            yearMonthLabel.text = String(format: "%d%@%d%@", history.dynamicDate.year(), LString("UI:Year"), history.dynamicDate.month(), LString("UI:Month"))
        }
    }
    
    @objc func reloadData() {
        self.startAnimating()
        history.reloadHistory { (success, msg) in
            self.stopAnimating()
            if success {
                NotificationCenter.default.post(name: .loadHistoryFinished, object: nil)
            } else {
                self.ui.showAlert(msg!, controller: self)
            }
        }
    }
}

extension HistoryViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.endHour - history.startHour
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! HistoryTimeCell
        cell.startLabel.text = String(format: "%02d:\n00", indexPath.row + history.startHour)
        cell.endLabel.text = String(format: "%02d:\n59", indexPath.row + history.startHour)
        cell.selectionStyle = .none
        return cell
    }
    
}

extension HistoryViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.ui.contentOffSet = scrollView.contentOffset
    }
}

class HistoryTimeCell: UITableViewCell {
    @IBOutlet var startLabel: UILabel!
    @IBOutlet var endLabel: UILabel!
}
