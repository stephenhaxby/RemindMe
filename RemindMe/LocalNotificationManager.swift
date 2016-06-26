//
//  LocalNotificationManager.swift
//  RemindMe
//
//  Created by Stephen Haxby on 1/06/2016.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import Foundation
import UIKit

class LocalNotificationManager {
    
    func getReminderNotification(remindMeItem : RemindMeItem) -> UILocalNotification? {
        
        var reminderNotification : UILocalNotification?
        
        for notification in UIApplication.sharedApplication().scheduledLocalNotifications! as [UILocalNotification] {
            
            if (notification.userInfo!["UUID"] as! String == remindMeItem.id) {
                
                reminderNotification = notification
                
                break
            }
        }
        
        return reminderNotification
    }
    
    func clearReminderNotification(remindMeItem : RemindMeItem) {
        
        if let reminderNotification : UILocalNotification = getReminderNotification(remindMeItem) {
            
            UIApplication.sharedApplication().cancelLocalNotification(reminderNotification)
        }
    }
    
    func setReminderNotification(remindMeItem : RemindMeItem) {
        
        var reminderNotification : UILocalNotification? = getReminderNotification(remindMeItem)
        
        if reminderNotification == nil {
            
            // create a corresponding local notification
            reminderNotification = UILocalNotification()
            reminderNotification!.alertBody = remindMeItem.title // text that will be displayed in the notification
            reminderNotification!.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
            
            reminderNotification!.soundName = UILocalNotificationDefaultSoundName // play default sound
            reminderNotification!.userInfo = ["UUID": remindMeItem.id] // assign a unique identifier to the notification so that we can retrieve it later
            //notification.category = "RemindMeItem_Category"
            
            UIApplication.sharedApplication().scheduleLocalNotification(reminderNotification!)
        }
        
        reminderNotification!.fireDate = remindMeItem.date // item due date (when notification will be fired)
    }

}