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
    
    let history = HistoryManager.sharedInstance()
    var route: RouteAdding = RouteAdding()
    var format: String = "yyyy/MM/dd"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        baseView.layer.borderColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        baseView.layer.borderWidth = 1
        baseView.layer.cornerRadius = 15
        baseView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        
        route.startDate = Date().stringDate(format)
        
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
        let date: Date? = route.startDate != nil ? Date.getDateFromString(route.startDate!, format: format) : nil
        DatePickerView.presentPicker(field, defaultDate: date) { (date) in
            self.route.startDate = date.stringDate(self.format)
            self.setDefaultData()
        }
    }
    
    func showStartTime(_ field: UITextField) {
        var list: [String] = []
        list.append(contentsOf: history.getStartTimeList())
        let index = route.startTime != nil ? list.index(of: route.startTime!) : 0
        PickerView.presentPicker(field, defaultIndex: index, dataList: list) { (timeStr, index) in
            self.route.startTime = timeStr
            let list = self.history.getEndTimeList(startTime: timeStr)
            self.route.endTime = list.count > 2 ? list[2] : list.last
            self.setDefaultData()
        }
    }
    
    func showEndTime(_ field: UITextField) {
        var list: [String] = []
        if route.startTime != nil {
            list.append(contentsOf: history.getEndTimeList(startTime: route.startTime!))
        }else {
            list.append(contentsOf: history.getStartTimeList())
        }
        let index = route.endTime != nil ? list.index(of: route.endTime!) : 0
        PickerView.presentPicker(field, defaultIndex: index, dataList: list) { (timeStr, index) in
            self.route.endTime = timeStr
            self.setDefaultData()
        }
    }
    
    func setDefaultData() {
        nameLabel.text = app.user?.name
        
        dateField.text = route.startDate
        startTimeField.text = route.startTime
        endTimeField.text = route.endTime
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
