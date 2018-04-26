//
//  AddRouteViewController.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 25/12/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit
import Firebase

class AddRouteViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var pictureImg: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var routeNameField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var startTimeField: UITextField!
    @IBOutlet weak var endTimeField: UITextField!
    
    var route: RouteAdding = RouteAdding()
    var date: Date = Date()
    var sDate: Date?
    var eDate: Date?
    
    var format1: String = "yyyy/MM/dd"
    var format2: String = "HH:mm"
    var format3: String = "yyyy/MM/dd HH:mm"
    
    @IBAction func donePressed(_ sender: UIBarItem) {
        self.view.endEditing(true)
        
        routeNameField.endEditing(true)
        route.name = routeNameField.text
        route.lineUserId = app.user?.lineUserId
        route.startTime = sDate?.toJSONformat()
        route.endTime = eDate?.toJSONformat()
        
        let verify = route.verifyData()
        guard verify.0 else {
            ui.showAlert(verify.1!, controller: self)
            return
        }
        
        self.startAnimating()
        feed.addtRoute(route, success: { (route) in
            self.stopAnimating()
            self.navigationController?.popViewController(animated: true)
            NotificationCenter.default.post(name: .needReloadRoute, object: nil)
        }) { (msg) in
            self.stopAnimating()
            self.ui.showAlert(msg, controller: self)
        }
    }
    
    @IBAction func datePressed(_ sender: UIButton) {
        DatePickerView.presentPicker(sender, defaultDate: date) { [weak self] (date) in
            self?.date = date
            self?.setDefaultData()
        }
    }
    
    @IBAction func startTimePressed(_ sender: UIButton) {
        var list: [String] = []
        list.append(contentsOf: history.getStartTimeList())
        let index = sDate?.stringDate(format2) != nil ? list.index(of: (sDate?.stringDate(format2))!) : 0
        PickerView.presentPicker(sender, defaultIndex: index, dataList: list) { [weak self] (timeStr, index) in
            self?.sDate = Date.getDateFromString("\(String(format: "%@", (self?.date.stringDate((self?.format1)!))!)) \(timeStr)", format: (self?.format3)!)
            let list = self?.history.getEndTimeList(startTime: timeStr)
            let eDateStr: String = list!.count > 2 ? list![2] : list!.last!
            self?.eDate = Date.getDateFromString("\(String(format: "%@", (self?.date.stringDate((self?.format1)!))!)) \(eDateStr)", format: (self?.format3)!)
            self?.setDefaultData()
        }
    }
    
    @IBAction func endTimePressed(_ sender: UIButton) {
        var list: [String] = []
        if sDate != nil {
            list.append(contentsOf: history.getEndTimeList(startTime: (sDate?.stringDate(format2))!))
        }else {
            list.append(contentsOf: history.getStartTimeList())
        }
        let index = endTimeField.text != nil && !(endTimeField.text?.isEmpty)! ? list.index(of: endTimeField.text!) : 0
        PickerView.presentPicker(sender, defaultIndex: index, dataList: list) { [weak self] (timeStr, index) in
            self?.eDate = Date.getDateFromString("\(String(format: "%@", (self?.date.stringDate((self?.format1)!))!)) \(timeStr)", format: (self?.format3)!)
            self?.setDefaultData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Analytics.logEvent(Analytics_History_Route_Add, parameters: [Analytics_User : String(format: "%@", (app.user?._id)!) as Any])

        baseView.layer.borderColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        baseView.layer.borderWidth = 1
        baseView.layer.cornerRadius = 15
        baseView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        
        routeNameField.text = "這是一個測試 \(Date().stringDate("yyyyMMddHHmm"))"
        
        do {
            var picture = try UIImage(data: Data(contentsOf: URL(fileURLWithPath: self.line.getLocalicturePath())))
            picture = picture?.resizeImage(newWidth: 100)
            picture = picture?.circleMasked
            pictureImg?.image = picture
        }catch {}
        
        setDefaultData()
        editingView = baseView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setDefaultData() {
        nameLabel.text = app.user?.name
        
        dateField.text = date.stringDate(format1)
        startTimeField.text = sDate?.stringDate(format2)
        endTimeField.text = eDate?.stringDate(format2)
    }
}
