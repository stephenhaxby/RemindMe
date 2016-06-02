//
//  Constants.swift
//  RemindMe
//
//  Created by Stephen Haxby on 30/11/2015.
//  Copyright © 2015 Stephen Haxby. All rights reserved.
//

import Foundation

class Constants{

    struct ReminderItemTableViewCell {
        
        static let EmptyCell : String = "<EMPTY_CELL>"
        
        static let NewItemCell : String = "<NEW_ITEM_CELL>"
    }
    
    static let RemindersListName : String = "Reminders"
    
    static let Setting : String = "Setting"
    
    static let MorningTimeText : String = "MorningTimeText"
    
    static let MorningAlertTime : String = "MorningAlertTime"
    
    static let DefaultMorningTimeText : String = "In the Morning"
    
    static let DefaultMorningTime : NSDate = NSDateManager.currentDateWithHour(7, minute: 0, second: 0)
    
    static let AfternoonTimeText : String = "AfternoonTimeText"
    
    static let AfternoonAlertTime : String = "AfternoonAlertTime"
    
    static let DefaultAfternoonTimeText : String = "Tonight"
    
    static let DefaultAfternoonTime : NSDate = NSDateManager.currentDateWithHour(18, minute: 0, second: 0)
    
    static let RefreshNotificationName : String = "Refresh"
}