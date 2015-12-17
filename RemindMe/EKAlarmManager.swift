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

    static func getFirstAlarmFromAlarms(alarms : [EKAlarm]?) -> EKAlarm? {
        
        if let alarms : [EKAlarm] = alarms {
            
            if alarms.count > 0 {
                
                return alarms[0]
            }
        }
        
        return nil
    }
    
    static func getAbsoluteDateFromAlarm(alarm : EKAlarm?) -> NSDate? {
        
        if let alarm : EKAlarm = alarm {
            
            if let date : NSDate = alarm.absoluteDate {
                
                return date
            }
        }
        
        return nil
    }
    
    static func getFirstAbsoluteDateComponentsFromAlarms(alarms : [EKAlarm]?) -> NSDateComponents? {
        
        if let alarm : EKAlarm = getFirstAlarmFromAlarms(alarms) {
                
            return getAbsoluteDateComponentsFromAlarm(alarm)
        }
        
        return nil
    }
    
    static func getAbsoluteDateComponentsFromAlarm(alarm : EKAlarm?) -> NSDateComponents? {
        
        if let date : NSDate = getAbsoluteDateFromAlarm(alarm) {
            
            return NSDateManager.getDateComponentsFromDate(date)
        }
        
        return nil
    }
}