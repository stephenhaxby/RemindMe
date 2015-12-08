//
//  NSDateManager.swift
//  RemindMe
//
//  Created by Stephen Haxby on 7/12/2015.
//  Copyright © 2015 Stephen Haxby. All rights reserved.
//

import Foundation

class NSDateManager {
    
    static func currentDateWithHour(hour : Int, minute : Int, second : Int) -> NSDate {
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        
        let dateComponents : NSDateComponents = NSDateComponents()
        dateComponents.year = calendar.component(NSCalendarUnit.Year, fromDate: date)
        dateComponents.month = calendar.component(NSCalendarUnit.Month, fromDate: date)
        dateComponents.day = calendar.component(NSCalendarUnit.Day, fromDate: date)
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        
        return newDateFrom(dateComponents)
    }
    
    static func dateWithDay(day : Int, month : Int, year : Int) -> NSDate {
        
        let dateComponents : NSDateComponents = NSDateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day

        return newDateFrom(dateComponents)
    }
    
    static func dateStringFromComponents(dateComponents : NSDateComponents) -> String {
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        
        let currentDateComponents : NSDateComponents = NSDateComponents()
        
        currentDateComponents.calendar = calendar
        currentDateComponents.year = calendar.component(NSCalendarUnit.Year, fromDate: date)
        currentDateComponents.month = calendar.component(NSCalendarUnit.Month, fromDate: date)
        currentDateComponents.day = calendar.component(NSCalendarUnit.Day, fromDate: date)
        currentDateComponents.hour = dateComponents.hour
        currentDateComponents.minute = dateComponents.minute
        currentDateComponents.second = dateComponents.second
        
        let currentDate : NSDate? = currentDateComponents.date
        let dateComponentsDate : NSDate? = dateComponents.date
        
        let dateCompareResult = currentDate!.compare(dateComponentsDate!)
        
        let displayHour = (dateComponents.hour > 12) ? dateComponents.hour-12 : dateComponents.hour
        let displayMinute = (dateComponents.minute < 10) ? "0\(dateComponents.minute)" : String(dateComponents.minute)
        let displayAMPM = (dateComponents.hour > 12) ? "PM" : "AM"
        
        let timeString : String = "\(displayHour):\(displayMinute) \(displayAMPM)"
        
        var dateString : String
        
        switch dateCompareResult {
            
        case NSComparisonResult.OrderedSame:
            dateString = "Today, \(timeString)"
            break
        case NSComparisonResult.OrderedDescending:
            
            if dateComponents.year == currentDateComponents.year
                && dateComponents.year == currentDateComponents.year
                && dateComponents.day == currentDateComponents.day-1 {
                
                dateString = "Yesterday, \(timeString)"
            }
            else {
                
                dateString = "\(dateComponents.day)/\(dateComponents.month)/\(dateComponents.year), \(timeString)"
            }
            break
        case NSComparisonResult.OrderedAscending:
            dateString = "Tomorrow, \(timeString)"
            break
        }
        
        return dateString
    }
    
    private static func newDateFrom(components : NSDateComponents) -> NSDate {
        
        let gregorian = NSCalendar(identifier:NSCalendarIdentifierGregorian)
        let date = gregorian!.dateFromComponents(components)
        
        return date!
    }
}