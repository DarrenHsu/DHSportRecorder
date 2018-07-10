//
//  HistoryPageViewController.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 23/12/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

class HistoryPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    let history: HistoryManager = HistoryManager.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.dataSource = self
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "HistoryCalendarViewController") as! HistoryCalendarViewController
        
        self.setViewControllers([controller], direction: .forward, animated: false, completion: nil)
    }
    
    // MARK: - UIPageViewControllerDataSource Methods
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "HistoryCalendarViewController") as! HistoryCalendarViewController
        controller.today = history.dynamicDate.increaseDay(day: -7)
        return controller
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "HistoryCalendarViewController") as! HistoryCalendarViewController
        controller.today = history.dynamicDate.increaseDay(day: 7)
        return controller
    }

    // MARK: - UIPageViewControllerDelegate Methods
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let controller = pageViewController.viewControllers?.first as! HistoryCalendarViewController
        history.dynamicDate = controller.today
    }
}
