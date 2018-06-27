//
//  HealthManager.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 2018/6/27.
//  Copyright © 2018 D.H. All rights reserved.
//

import UIKit
import HealthKit

class HealthManager: NSObject {
    
    private static var _manager: HealthManager?
    
    public static func sharedInstance() -> HealthManager {
        if _manager == nil {
            _manager = HealthManager()
        }
        return _manager!
    }
    
    var healthStore: HKHealthStore?
    
    func requestHealthAvaliable(completion: @escaping (Bool) -> Void) {
        if HKHealthStore.isHealthDataAvailable() {
            let allTypes = Set([HKObjectType.quantityType(forIdentifier: .stepCount)!])
            
            healthStore = HKHealthStore()
            healthStore?.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
                completion(success)
            }
        }else {
            completion(false)
        }
    }
    
    func getTodaysSteps(completion: @escaping (Double) -> Void) {
        if let healthStore = self.healthStore {
            let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
            
            let now = Date()
            let startOfDay = Calendar.current.startOfDay(for: now)
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
            
            let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                guard let result = result, let sum = result.sumQuantity() else {
                    completion(0.0)
                    return
                }
                completion(sum.doubleValue(for: HKUnit.count()))
            }
            
            healthStore.execute(query)
        }
    }
}
