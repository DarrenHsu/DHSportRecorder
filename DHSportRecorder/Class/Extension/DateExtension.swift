//
//  DateExtension.swift
//  DHYoutube
//
//  Created by Darren Hsu on 18/10/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

extension Date {
    func toLocalTime() -> Date {
        let timeZone = TimeZone.autoupdatingCurrent
        let seconds : TimeInterval = Double(timeZone.secondsFromGMT(for: self))
        let localDate = Date(timeInterval: seconds, since: self)
        return localDate
    }
    
    func isGreaterThanDate(_ dateToCompare: Date) -> Bool {
        return self.compare(dateToCompare) == ComparisonResult.orderedDescending
    }
    
    func isLessThanDate(_ dateToCompare: Date) -> Bool {
        return self.compare(dateToCompare) == ComparisonResult.orderedAscending
    }
    
    func toJSONformat() -> String {
        let dateFormatterDate = DateFormatter()
        dateFormatterDate.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS'Z'"
        let dateStr = dateFormatterDate.string(from: self)
        let startDateStr = String(dateStr.characters.map {
            $0 == " " ? "T" : $0
        })
        let startDate = startDateStr
        return startDate
    }
    
}

func convertJSONtoDate(json: String) -> Date {
    let dateFormatterDate = DateFormatter()
    dateFormatterDate.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSz"
    let timeZone: TimeZone = TimeZone(secondsFromGMT: 0)!
    dateFormatterDate.timeZone = timeZone
    let calendar = Calendar(identifier: .gregorian)
    dateFormatterDate.calendar = calendar
    let date = dateFormatterDate.date(from: json)
    return date!
}
