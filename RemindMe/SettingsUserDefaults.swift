//
//  SettingsUserDefaults.swift
//  ReminderSorter
//
//  Created by Stephen Haxby on 17/11/2015.
//  Copyright © 2015 Stephen Haxby. All rights reserved.
//

import Foundation

class SettingsUserDefaults{
    
    static var useICloudReminders: Bool {
        
        return NSUserDefaults.standardUserDefaults().boolForKey("useICloudReminders")
    }
}