//
//  HistoryViewController.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 08/11/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

class HistoryViewController: BaseViewController {
    
    @IBOutlet var timeTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui.addObserver(self, forKeyPath: "contentOffSet" , options: [.new, .old], context: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffSet" {
            timeTable.contentOffset = ui.contentOffSet
        }
    }
}

extension HistoryViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 24
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! HistoryTimeCell
        cell.startLabel.text = String(format: "%02d:\n00", indexPath.row)
        cell.endLabel.text = String(format: "%02d:\n59", indexPath.row)
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
