//
//  HistoryPageViewController.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 23/12/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

class HistoryPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    deinit {
        print("HistoryPageViewController deint")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.dataSource = self
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "HistoryCalendarViewController") as! HistoryCalendarViewController
        
        self.setViewControllers([controller], direction: .forward, animated: false, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UIPageViewControllerDataSource Methods
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "HistoryCalendarViewController") as! HistoryCalendarViewController
    
        return controller
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "HistoryCalendarViewController") as! HistoryCalendarViewController
        
        return controller
    }

    // MARK: - UIPageViewControllerDelegate Methods
    
    
}
