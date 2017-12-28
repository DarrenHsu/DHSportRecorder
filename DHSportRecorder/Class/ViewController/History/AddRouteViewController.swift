//
//  AddRouteViewController.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 25/12/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

class AddRouteViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var routeNameField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var startTimeField: UITextField!
    @IBOutlet weak var endTimeField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        baseView.layer.borderColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        baseView.layer.borderWidth = 1
        baseView.layer.cornerRadius = 15
        baseView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showDate(){
        
    }
    
    func showStartTime() {
        
    }
    
    func showEndTime() {
        
    }
    
    // MARK: - UITextFieldDelegate Methods
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        return false
    }

}
