//
//  EKAlarmManager.swift
//  RemindMe
//
//  Created by Stephen Haxby on 17/12/2015.
//  Copyright © 2015 Stephen Haxby. All rights reserved.
//

import Foundation
import EventKitUI

class EKAlarmManager {

    static func getFirstAlarmFromAlarms(_ alarms : [EKAlarm]?) -> EKAlarm? {
        
        if let alarms : [EKAlarm] = alarms {
            
            if alarms.count > 0 {
                
                return alarms[0]
            }
        }
        
        return nil
    }
    
    static func getAbsoluteDateFromAlarm(_ alarm : EKAlarm?) -> Date? {
        
        if let alarm : EKAlarm = alarm {
            
            if let date : Date = alarm.absoluteDate {
                
                return date
            }
        }
        
        return nil
    }
    
    static func getFirstAbsoluteDateComponentsFromAlarms(_ alarms : [EKAlarm]?) -> DateComponents? {
        
        if let alarm : EKAlarm = getFirstAlarmFromAlarms(alarms) {
                
            return getAbsoluteDateComponentsFromAlarm(alarm)
        }
        
        return nil
    }
    
    static func getAbsoluteDateComponentsFromAlarm(_ alarm : EKAlarm?) -> DateComponents? {
        
        if let date : Date = getAbsoluteDateFromAlarm(alarm) {
            
            return NSDateManager.getDateComponentsFromDate(date)
        }
        
        return nil
    }
}
