//
//  CaloriesHelpers.swift
//  DHSportRecorder
//
//  Created by Darren Hsu on 2018/6/26.
//  Copyright © 2018 D.H. All rights reserved.
//

import UIKit

class CaloriesHelpers {
    
    public static func getCalories(speed: Double, weight: Double, minutes: Double) -> Double {
        return (getGeneralMets(speed) * weight / 60.0) * minutes
    }
    
    public static func getGeneralMets(_ speed: Double) -> Double {
        return speed
    }
    
    public static func getMets(_ speed: Double) -> Double {
        if speed > 0 && speed < 2.7 {
            return 1.0
        } else if speed >= 2.7 && speed  < 4 {
            return 2.3
        } else if speed >= 4 && speed  < 4.8 {
            return 2.8
        } else if speed >= 4.8 && speed  < 5.5 {
            return 3.3
        } else if speed >= 5.5 && speed  < 6.6 {
            return 3.5
        } else if speed >= 6.6 && speed  < 8 {
            return 6
        } else if speed >= 8 && speed  < 10 {
            return 8.3
        } else if speed >= 10 && speed  < 12.5 {
            return 9.8
        } else if speed >= 12.5 && speed  < 15 {
            return 11.5
        } else if speed >= 15 && speed  < 18 {
            return 12.8
        } else if speed >= 18.2 && speed  < 23.2 {
            return 16
        } else if speed > 23.2 {
            return 23
        } else {
            return 0
        }
    }
    

}
