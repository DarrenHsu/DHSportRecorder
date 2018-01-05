//
//  DatePickerView.swift
//  AgentPlusiPadPlatform
//
//  Created by Darren Hsu on 22/12/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

class DatePickerView: PickerView {

    @IBOutlet var datePicker: UIDatePicker!
    
    var didSelectedDate: ((_ date: Date) -> ())?
    
    @IBAction override func submitPressed(_ sender: UIButton) {
        didSelectedDate?(datePicker.date)
        popover.dismiss()
    }
    
    class func presentPicker(_ sourceView: UIView, defaultDate: Date? = nil, handleSelected: @escaping (Date)->()) {
        let pickerView: DatePickerView = UINib(nibName: "DatePickerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! DatePickerView
        pickerView.didSelectedDate = handleSelected
        
        if defaultDate != nil {
            pickerView.datePicker.date = defaultDate!
        }
        
        self.presentSelf(pickerView, sourceView: sourceView)
    }
}
