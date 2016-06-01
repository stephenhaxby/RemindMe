//
//  iCloudReminderFacade.swift
//  RemindMe
//
//  Created by Stephen Haxby on 5/01/2016.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import Foundation
import EventKit

class iCloudReminderFacade : StorageFacadeProtocol {
    
    var eventStoreObserver : NSObjectProtocol?
    
    var icloudReminderManager : iCloudReminderManager! = nil
    
    var returnRemindersFunc : ([RemindMeItem] -> ())?
    
    init (icloudReminderManager : iCloudReminderManager) {
    
        // Sets the method to run when the Event Store is updated in the background
        eventStoreObserver = NSNotificationCenter.defaultCenter().addObserverForName(EKEventStoreChangedNotification, object: nil, queue: nil){
            (notification) -> Void in
            
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.RefreshNotificationName, object: nil)
        }
    
        self.icloudReminderManager = icloudReminderManager
        
        // Set the name of the reminder list we are going to use
        self.icloudReminderManager.remindersListName = Constants.RemindersListName
        
        // Request access to Reminders
        self.icloudReminderManager.requestAccessToReminders(accessGranted)
    }
    
    func accessGranted(granted : Bool) {
                
    }
    
    func createNewReminder() -> RemindMeItem {
    
        return getReminderItemFrom(icloudReminderManager.getNewReminder()!)
    } 
    
    func createNewReminder(name : String, time : NSDate) -> RemindMeItem {
        
        let reminder : EKReminder = icloudReminderManager.getNewReminder()!
        
        reminder.title = name       
        
        var newAlarms : [EKAlarm] = [EKAlarm]()
        newAlarms.append(EKAlarm(absoluteDate: time))        
        reminder.alarms = newAlarms
        
        return getReminderItemFrom(reminder)
    }

    func updateReminder(remindMeItem : RemindMeItem) {
        
        icloudReminderManager.getReminder(remindMeItem.title, date: remindMeItem.date!) {
            reminder in
            
            if let matchingReminder : EKReminder = reminder {
            
                matchingReminder.title = remindMeItem.title
                matchingReminder.alarms = [EKAlarm(absoluteDate : remindMeItem.date!)]
                
                self.icloudReminderManager.saveReminder(matchingReminder)
            }
        }
    }
    
    func removeReminder(remindMeItem : RemindMeItem) {
        
        icloudReminderManager.getReminder(remindMeItem.title, date: remindMeItem.date!) {
            reminder in
            
            if let matchingReminder : EKReminder = reminder {
                
                matchingReminder.title = remindMeItem.title
                matchingReminder.alarms = [EKAlarm(absoluteDate : remindMeItem.date!)]
                
                self.icloudReminderManager.removeReminder(matchingReminder)
            }
        }
    }
    
    //Expects a function that has a parameter that's an array of RemindMeItem
    func getReminders(returnReminders : [RemindMeItem] -> ()){
    
        returnRemindersFunc = returnReminders
        
        icloudReminderManager.getReminders(getiCloudReminders)
    }
    
    private func getiCloudReminders(iCloudShoppingList : [EKReminder]){
    
        returnRemindersFunc!(iCloudShoppingList.map({
            
            (reminder : EKReminder) -> RemindMeItem in
            
            return getReminderItemFrom(reminder)
        }))
    }
    
    func commit() -> Bool {
        
        return icloudReminderManager.commit()
    }

    func getReminderItemFrom(reminder : EKReminder) -> RemindMeItem {
    
        let remindMeItem : RemindMeItem = RemindMeItem()
        
        remindMeItem.id = reminder.calendarItemIdentifier
        remindMeItem.title = reminder.title

        if reminder.alarms != nil && reminder.alarms!.count > 0 {
        
            remindMeItem.date = reminder.alarms!.first!.absoluteDate!
        }
        
        return remindMeItem
    }
}



    

