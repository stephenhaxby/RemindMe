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
    
    func getPendingReminderNotificationRequests(getUNNotificationRequests : @escaping ([UNNotificationRequest]) -> ()) {
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            getUNNotificationRequests(requests)
        }
    }
    
    func getDeliveredReminderNotificationRequests(getUNNotificationRequests : @escaping ([UNNotificationRequest]) -> ()) {
        
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            
            var requests : [UNNotificationRequest] = [UNNotificationRequest]()
            
            for notification in notifications {
                
                requests.append(notification.request)
            }

            getUNNotificationRequests(requests)
        }
    }
    
    func removePendingReminderNotificationRequest(remindMeItem : RemindMeItem) {
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            
            if let calendarNotification : UNNotificationRequest =
                self.getNotificationRequest(identifier: remindMeItem.id, notifications: requests) {
                
                UNUserNotificationCenter.current().removePendingNotificationRequests(
                    withIdentifiers: [calendarNotification.identifier])
            }
        }
    }
    
    func removeDeliveredReminderNotification(remindMeItem : RemindMeItem) {
        
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            
            var requests : [UNNotificationRequest] = [UNNotificationRequest]()
            
            for notification in notifications {
                
                requests.append(notification.request)
            }
            
            if let calendarNotification : UNNotificationRequest =
                self.getNotificationRequest(identifier: remindMeItem.id, notifications: requests) {
                
                UNUserNotificationCenter.current().removeDeliveredNotifications(
                    withIdentifiers: [calendarNotification.identifier])
            }
        }
    }
    
    func getNotificationRequest(identifier : String, notifications : [UNNotificationRequest]) -> UNNotificationRequest? {
        
        var reminderNotification : UNNotificationRequest?
        
        let notificationIndex : Int? =
            notifications.index(where: {(notification : UNNotificationRequest) in notification.identifier.hasPrefix(identifier)})
        
        if notificationIndex != nil {
            
            reminderNotification = notifications[notificationIndex!]
        }
        
        return reminderNotification
    }
    
    func clearReminderNotification(remindMeItem : RemindMeItem) {
        
        removePendingReminderNotificationRequest(remindMeItem: remindMeItem)
        
        removeDeliveredReminderNotification(remindMeItem: remindMeItem)
    }
    
    func setReminderNotification(_ remindMeItem : RemindMeItem) {
        
        clearReminderNotification(remindMeItem: remindMeItem)
        
        let notification = UNMutableNotificationContent()
        
        notification.categoryIdentifier = Constants.NotificationCategory
        
        notification.title = "Don't forget to:"
        notification.body = remindMeItem.title
        
        var trigger : UNNotificationTrigger?
        
        switch remindMeItem.type {
            case Constants.ReminderType.dateTime:
                
                trigger = UNCalendarNotificationTrigger(
                    dateMatching: NSDateManager.getDateComponentsFromDate(remindMeItem.date!),
                    repeats: false)
            
            case Constants.ReminderType.location:
            
                let center = CLLocationCoordinate2DMake(remindMeItem.latitude!, remindMeItem.longitude!)
                let region = CLCircularRegion.init(center: center, radius: 100.0,
                                                   identifier: remindMeItem.id)
                region.notifyOnEntry = true;
                region.notifyOnExit = false;
                
                trigger = UNLocationNotificationTrigger(region: region, repeats: false)
            
            default:
                Utilities().diaplayError(message: "No reminder type could be found for \(remindMeItem.title)")
                return
        }
        
        //NOTE: As the find/remove methods are async, we could create a new request with this id before the old on has been deleted
        //      thus our new notification could be removed. The find method needs to use has prefix instead...
        let request = UNNotificationRequest(
            identifier: remindMeItem.id.appending(UUID().uuidString),
            content: notification,
            trigger: trigger!
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}
