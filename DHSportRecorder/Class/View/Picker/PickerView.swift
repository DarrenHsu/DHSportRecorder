//
//  PickerView.swift
//  AgentPlusiPadPlatform
//
//  Created by Darren Hsu on 22/12/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit
import Popover

class PickerView: UIView, UIPickerViewDataSource, UIPickerViewDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var picker: UIPickerView!
    
    var aryList: [String] = []
    var indexSelected: Int = 0
    
    var didSelectedStringAndIndex: ((_ text: String, _ index: Int) -> ())?
    
    var presentController: PickerViewController?
    
    var popover: Popover?
    
    deinit {
        print("deinit")
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        popover?.dismiss()
    }
    
    @IBAction func submitPressed(_ sender: UIButton) {
        didSelectedStringAndIndex?(self.aryList[self.indexSelected], self.indexSelected)
        popover?.dismiss()
    }

    class func presentPicker(_ sourceView: UIView, defaultIndex: Int? = nil, dataList: [String], popoverType: PopoverType? = nil, handleSelected: @escaping (String, Int)->()) {
        let pickerView: PickerView = UINib(nibName: "PickerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! PickerView
        pickerView.aryList = dataList
        pickerView.didSelectedStringAndIndex = handleSelected
        
        if defaultIndex != nil {
            pickerView.indexSelected = defaultIndex!
            pickerView.picker.selectRow(defaultIndex!, inComponent: 0, animated: false)
        }
        
        presentSelf(pickerView, sourceView: sourceView, popoverType: popoverType)
    }
    
     class func presentSelf(_ pickerView: PickerView, sourceView: UIView, popoverType: PopoverType?) {
        if pickerView.popover == nil {
            let options = [
                .type(popoverType != nil ? popoverType! : .up),
                .cornerRadius(15),
                .animationIn(0.3),
                ] as [PopoverOption]
            
            pickerView.popover = Popover(options: options)
        }
        
        let rect = pickerView.frame
        pickerView.popover?.willShowHandler = { [weak pickerView] () in
            pickerView?.frame = rect
        }
        pickerView.popover?.show(pickerView, fromView: sourceView)
    }
    
    fileprivate class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        
        return base
    }
    
    // MARK: - UIPopoverPresentationControllerDelegate Methods
    public func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        self.presentController = nil
    }
    
    // MARK: - UIPickerDataSource Methods
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.aryList.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    // MARK: - UIPickerDataDelegate Methods
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.aryList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.indexSelected = row
    }
}

class PickerViewController: UIViewController {}
