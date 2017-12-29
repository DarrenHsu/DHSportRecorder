//
//  DateExtension.swift
//  DHYoutube
//
//  Created by Darren Hsu on 18/10/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import UIKit

extension Date {
    static let JSONFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    
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
        dateFormatterDate.dateFormat = Date.JSONFormat
        let dateStr = dateFormatterDate.string(from: self)
//        let startDateStr = String(dateStr.characters.map {
//            $0 == " " ? "T" : $0
//        })
//        let startDate = startDateStr
        return dateStr
    }
    
    static func today() -> Date {
        let dateComponents = DateComponents(year:Date().year(),month:Date().month(),day:Date().day())
        return Calendar.current.date(from: dateComponents)!
    }
    
    func getDate(_ day : Int) ->Date {
        let dateComponents = DateComponents(year:self.year(),month:self.month(),day:day)
        return Calendar.current.date(from: dateComponents)!
    }
    
    func stringDate(_ format:String) -> String {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func addDay(_ day : Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.day = day
        let calendar = Calendar.current
        let date = calendar.date(byAdding: dateComponents, to: self)
        
        return date!
    }
    
    func lastWeek() -> Date {
        var dateComponents = DateComponents()
        dateComponents.day = -7
        let calendar = Calendar.current
        let date = calendar.date(byAdding: dateComponents, to: self)
        
        return date!
    }
    
    func nextWeek() -> Date {
        var dateComponents = DateComponents()
        dateComponents.day = 7
        let calendar = Calendar.current
        let date = calendar.date(byAdding: dateComponents, to: self)
        
        return date!
    }
    
    func lastMonth() -> Date {
        var dateComponents = DateComponents()
        dateComponents.month = -1
        let calendar = Calendar.current
        let date = calendar.date(byAdding: dateComponents, to: self)
        
        return date!
    }
    
    func nextMonth() -> Date {
        var dateComponents = DateComponents()
        dateComponents.month = 1
        let calendar = Calendar.current
        let date = calendar.date(byAdding: dateComponents, to: self)
        
        return date!
    }
    
    func offsetYears(offsetYear : Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = offsetYear
        let calendar = Calendar.current
        let date = calendar.date(byAdding: dateComponents, to: self)
        
        return date!
    }
    
    func isEarlierThan(date : Date) -> Bool {
        if self.compare(date) == .orderedAscending {
            return true
        } else {
            return false
        }
    }
    
    func isSameDay(date : Date) -> Bool {
        if self.compare(date) == .orderedSame {
            return true
        } else {
            return false
        }
    }
    
    func weekDay() -> Int {
        let calendar : Calendar = Calendar.current
        return calendar.component(.weekday, from: self)-1
    }
    
    static func getDateFromString(_ strDate : String, format : String) -> Date {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.date(from: strDate)!
    }
    
    static func weekDayString(_ weekDay:Int) -> String? {
        if weekDay > 6 || weekDay < 0 {
            return ""
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        
        return dateFormatter.shortWeekdaySymbols[weekDay]
    }
    
    
    func day() -> Int {
        let calendar : Calendar = Calendar.current
        return calendar.component(.day, from: self)
    }
    
    func month() -> Int {
        let calendar : Calendar = Calendar.current
        return calendar.component(.month, from: self)
    }
    
    func year() -> Int {
        let calendar : Calendar = Calendar.current
        return calendar.component(.year, from: self)
    }
    
    func numberOfDays() -> Int {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: self)!
        
        return range.count
    }
    
    func firstWeekDayOfMonth() -> Int {
        let dateComponents = DateComponents(year: self.year(), month: self.month(), day:1)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
        
        return calendar.component(.weekday, from: date)-1
    }
    
    func isInRange(from: Date, to:Date) -> Bool {
        if(self.compare(from) == .orderedDescending ||
            self.compare(from) == .orderedSame)
        {
            if(self.compare(to) == .orderedAscending ||
                self.compare(to) == .orderedSame)
            {
                // date is in range
                return true
            }
        }
        // date is not in range
        return false
    }
    
    func getDayBetween(compareDate : Date) -> Int {
        let calendar = Calendar.current
        let date1 = calendar.startOfDay(for: self)
        let date2 = calendar.startOfDay(for: compareDate)
        
        let unitFlags = Set<Calendar.Component>([.day])
        let components = calendar.dateComponents(unitFlags, from: date1, to: date2)
        
        return components.day!
    }
    
    func increaseYear(year : Int) -> Date {
        let gregorian : Calendar = Calendar.init(identifier: .gregorian)
        var dateComponents = DateComponents.init()
        dateComponents.year = year
        return gregorian.date(byAdding: dateComponents, to: self)!
    }
    
    func increaseMonth(month : Int) -> Date {
        let gregorian : Calendar = Calendar.init(identifier: .gregorian)
        var dateComponents = DateComponents.init()
        dateComponents.month = month
        return gregorian.date(byAdding: dateComponents, to: self)!
    }
    
    func increaseDay(day : Int) -> Date {
        let gregorian : Calendar = Calendar.init(identifier: .gregorian)
        var dateComponents = DateComponents.init()
        dateComponents.day = day
        return gregorian.date(byAdding: dateComponents, to: self)!
    }
    
    func insurableYearSinceDate(date : Date) -> Int {
        var insureDate = date.increaseMonth(month: -6)
        insureDate = insureDate.increaseDay(day: 1)
        
        let ageComponents = Calendar.current.dateComponents([Calendar.Component.year, Calendar.Component.month, Calendar.Component.day], from: self, to: insureDate)
        let year : Int = -ageComponents.year!
        return year
    }
    
    func reportStateMinDate() -> Date {
        let insureDate = self.increaseYear(year: -1)
        return insureDate
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
