//
//  AddRouteViewController.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 25/12/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

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
    var format2: String = "HH:ss"
    var format3: String = "yyyy/MM/dd HH:ss"
    
    @IBAction func donePressed(_ sender: UIBarItem) {
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
        }) { (msg) in
            self.stopAnimating()
            self.ui.showAlert(msg, controller: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showDate(_ field: UITextField) {
        DatePickerView.presentPicker(field, defaultDate: date) { (date) in
            self.date = date
            self.setDefaultData()
        }
    }
    
    func showStartTime(_ field: UITextField) {
        var list: [String] = []
        list.append(contentsOf: history.getStartTimeList())
        let index = sDate?.stringDate(format2) != nil ? list.index(of: (sDate?.stringDate(format2))!) : 0
        PickerView.presentPicker(field, defaultIndex: index, dataList: list) { (timeStr, index) in
            self.sDate = Date.getDateFromString("\(self.date.stringDate(self.format1)) \(timeStr)", format: self.format3)
            let list = self.history.getEndTimeList(startTime: timeStr)
            let eDateStr: String = list.count > 2 ? list[2] : list.last!
            self.eDate = Date.getDateFromString("\(self.date.stringDate(self.format1)) \(eDateStr)", format: self.format3)
            self.setDefaultData()
        }
    }
    
    func showEndTime(_ field: UITextField) {
        var list: [String] = []
        if sDate != nil {
            list.append(contentsOf: history.getEndTimeList(startTime: (sDate?.stringDate(format2))!))
        }else {
            list.append(contentsOf: history.getStartTimeList())
        }
        let index = route.endTime != nil ? list.index(of: route.endTime!) : 0
        PickerView.presentPicker(field, defaultIndex: index, dataList: list) { (timeStr, index) in
            self.eDate = Date.getDateFromString("\(self.date.stringDate(self.format1)) \(timeStr)", format: self.format3)
            self.setDefaultData()
        }
    }
    
    func setDefaultData() {
        nameLabel.text = app.user?.name
        
        dateField.text = date.stringDate(format1)
        startTimeField.text = sDate?.stringDate(format2)
        endTimeField.text = eDate?.stringDate(format2)
    }
    
    // MARK: - UITextFieldDelegate Methods
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == dateField {
            showDate(textField)
        }else if textField == startTimeField {
            showStartTime(textField)
        }else if textField == endTimeField {
            showEndTime(textField)
        }
        
        return false
    }

}
