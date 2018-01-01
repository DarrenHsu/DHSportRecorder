//
//  UIManager.swift
//  DHYoutube
//
//  Created by Darren Hsu on 17/10/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

class UIManager: NSObject {
    
    private static var _manager: UIManager?
    
    public static func sharedInstance() -> UIManager {
        if _manager == nil {
            _manager = UIManager()
        }
        return _manager!
    }
    
    @objc public dynamic var contentOffSet: CGPoint = CGPoint.zero
    
    private var loadingSuperView: UIView!
    private var loadingLabel: UILabel!
    
    public func showAlert(_ msg: String, controller: UIViewController) {
        let alert : UIAlertController = UIAlertController.init(title: "提示", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        let callaction = UIAlertAction(title: "確定",style: .default, handler: nil);
        
        alert.addAction(callaction)
        controller.present(alert, animated: true, completion: nil)
    }
    
    public func showAlert(_ msg: String, controller: UIViewController, submit: (() -> Void)?) {
        let alert : UIAlertController = UIAlertController.init(title: "提示", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        let okCallaction = UIAlertAction(title: "確定", style: .default) { (action) in
            submit?()
        }
        
        alert.addAction(okCallaction)
        controller.present(alert, animated: true, completion: nil)
    }
    
    public func showAlert(_ msg: String, controller: UIViewController, submit: (() -> Void)?, cancel: (() -> Void)?) {
        let alert : UIAlertController = UIAlertController.init(title: "提示", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        let okCallaction = UIAlertAction(title: "確定", style: .default) { (action) in
            submit?()
        }
        
        let cancelCallaction = UIAlertAction(title: "取消", style: .default) { (action) in
            cancel?()
        }
        
        alert.addAction(cancelCallaction)
        alert.addAction(okCallaction)
        controller.present(alert, animated: true, completion: nil)
    }
    
    func showActionSheet(_ sender: UIView, controller: UIViewController, title: String, message: String? = nil, actionTitles: [String], actions: [(UIAlertAction)->Void]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alertController.modalPresentationStyle = .popover
        
        for i in 0..<actionTitles.count {
            let action = actions[i]
            let title = actionTitles[i]
            let alertAction = UIAlertAction(title: title, style: .default, handler: action)
            if title == LString("Item:Cancel") {
                alertAction.setValue(UIColor.blue, forKey: "titleTextColor")
            }else if title == LString("Item:Remove") {
                alertAction.setValue(UIColor.red, forKey: "titleTextColor")
            }else {
                alertAction.setValue(UIColor.black, forKey: "titleTextColor")
            }
            
            alertController.addAction(alertAction)
        }
        
        if let presenter = alertController.popoverPresentationController {
            presenter.sourceView = sender;
            presenter.sourceRect = sender.bounds;
        }
        controller.present(alertController, animated: true, completion: nil)
    }
}
