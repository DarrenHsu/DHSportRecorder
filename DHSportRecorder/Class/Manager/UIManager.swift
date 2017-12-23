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
    
    private var loading: CircleLoading!
    private var loadingSuperView: UIView!
    private var loadingLabel: UILabel!
    
    public func startLoading(_ view: UIView) {
        loadingSuperView = UIView(frame: view.bounds)
        loadingSuperView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
        
        loadingLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        loadingLabel.text = LString("Alert:Loading")
        loadingLabel.textColor = #colorLiteral(red: 0.3098039329, green: 0.01568627544, blue: 0.1294117719, alpha: 1)
        loadingLabel.font = UIFont(name: "Roboto-Regular", size: 20)
        loadingLabel.textAlignment = NSTextAlignment.center
        loadingLabel.center = loadingSuperView.center
        
        loadingSuperView.addSubview(loadingLabel)
        
        loading = CircleLoading(frame: CGRect(x: loadingLabel.frame.origin.x - 60, y: loadingLabel.frame.origin.y - 15, width: 60, height: 60))
        loading.colors(color1: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), color2: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), color3: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1))
        loading.start()
        
        loadingSuperView.addSubview(loading)
        
        view.addSubview(loadingSuperView)
    }
    
    public func stopLoading() {
        loading.stop()
        loadingSuperView.removeFromSuperview()
    }
    
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
}
