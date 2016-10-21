//
//  LocalNotificationManager.swift
//  RemindMe
//
//  Created by Stephen Haxby on 1/06/2016.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import Foundation
import UserNotifications
import CoreLocation

class LocalNotificationManager {
    
    func getPendingReminderNotificationRequest(_ remindMeItem : RemindMeItem) -> UNNotificationRequest? {
        
        var notifications : [UNNotificationRequest] = [UNNotificationRequest]()
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            
            notifications.append(contentsOf: requests)
        }
        
        return getNotificationRequest(identifier: remindMeItem.id, notifications: notifications)
    }
    
    func getDeliveredReminderNotificationRequest(_ remindMeItem : RemindMeItem) -> UNNotificationRequest? {
        
        var notifications : [UNNotificationRequest] = [UNNotificationRequest]()
        
        UNUserNotificationCenter.current().getDeliveredNotifications { requests in
            
            for notification in requests {
                
                notifications.append(notification.request)
            }
        }
        
        return getNotificationRequest(identifier: remindMeItem.id, notifications: notifications)
    }
    
    func getNotificationRequest(identifier : String, notifications : [UNNotificationRequest]) -> UNNotificationRequest? {
        
        var reminderNotification : UNNotificationRequest?
        
        let notificationIndex : Int? = notifications.index(where: {(notification : UNNotificationRequest) in notification.identifier == identifier})
        
        if notificationIndex != nil {
            
            reminderNotification = notifications[notificationIndex!]
        }
        
        return reminderNotification
    }
    
    func clearReminderNotification(_ remindMeItem : RemindMeItem) {
        
        if let pendingReminderNotification : UNNotificationRequest = getPendingReminderNotificationRequest(remindMeItem) {
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [pendingReminderNotification.identifier])
            
            return
        }
        
        if let deliveredReminderNotification : UNNotificationRequest = getDeliveredReminderNotificationRequest(remindMeItem) {
            
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [deliveredReminderNotification.identifier])
        }
    }
    
    func setReminderNotification(_ remindMeItem : RemindMeItem) {
        
        if let calendarNotification : UNNotificationRequest = getPendingReminderNotificationRequest(remindMeItem) {
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(
                withIdentifiers: [calendarNotification.identifier])
        }
        else if let calendarNotification : UNNotificationRequest = getDeliveredReminderNotificationRequest(remindMeItem) {
            
            UNUserNotificationCenter.current().removeDeliveredNotifications(
                withIdentifiers: [calendarNotification.identifier])
        }
        
        let notification = UNMutableNotificationContent()
        
        notification.categoryIdentifier = Constants.NotificationCategory
        
        notification.title = "Don't forget to:"
        notification.body = remindMeItem.title
        
        if remindMeItem.type == 0 {
            
            let request = UNNotificationRequest(
                identifier: remindMeItem.id,
                content: notification,
                trigger: UNCalendarNotificationTrigger(
                    dateMatching: NSDateManager.getDateComponentsFromDate(remindMeItem.date!),
                    repeats: false)
            )
            
            UNUserNotificationCenter.current().add(request)
        }
        else {
        
            TODO
            
            let center = CLLocationCoordinate2DMake(remindMeItem.latitude!, remindMeItem.longitude!)
            let region = CLCircularRegion.init(center: center, radius: 100.0,
                                               identifier: remindMeItem.id)
            region.notifyOnEntry = true;
            region.notifyOnExit = false;
            
            let request = UNNotificationRequest(
                identifier: remindMeItem.id,
                content: notification,
                trigger: UNLocationNotificationTrigger.init(region: region, repeats: false))
            
            UNUserNotificationCenter.current().add(request)
        }
    }
}
