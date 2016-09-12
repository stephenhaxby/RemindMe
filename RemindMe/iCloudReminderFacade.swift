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
            
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.RefreshNotification, object: nil)
        }
    
        self.icloudReminderManager = icloudReminderManager
        
        // Set the name of the reminder list we are going to use
        self.icloudReminderManager.remindersListName = Constants.RemindersListName
        
        // Request access to Reminders
        self.icloudReminderManager.requestAccessToReminders(accessGranted)
    }
    
    func accessGranted(granted : Bool) {
                
    }
    
    func createOrUpdateReminder(remindMeItem : RemindMeItem) {
        
        icloudReminderManager.getReminder(remindMeItem.id, reminderIdentifier: getReminderId) {
            reminder in
            
            if let matchingReminder : EKReminder = reminder {
                
                matchingReminder.title = remindMeItem.title
                matchingReminder.alarms = [EKAlarm(absoluteDate : remindMeItem.date!)]
                
                //We have to commit here because if we don't the alarms are NOT persisted... Nothing I can do about it
                self.icloudReminderManager.saveReminder(matchingReminder, commit: true)
            }
            else {
                
                let reminder : EKReminder = self.icloudReminderManager.getNewReminder()!
        
                reminder.title = remindMeItem.title
        
                var newAlarms : [EKAlarm] = [EKAlarm]()
                newAlarms.append(EKAlarm(absoluteDate: remindMeItem.date!))
                reminder.alarms = newAlarms
                
                //We have to commit here because if we don't the alarms are NOT persisted... Nothing I can do about it
                self.icloudReminderManager.saveReminder(reminder, commit: true)
            }
        }
    }
    
    func removeReminder(remindMeItem : RemindMeItem) {
        
        let reminderId : String = getReminderId(remindMeItem.title, date: remindMeItem.date!)
        
        icloudReminderManager.getReminder(reminderId, reminderIdentifier: getReminderId) {
            reminder in
            
            if let matchingReminder : EKReminder = reminder {
                
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
    
        //Only return reminders that have an alarm
        let reminderList : [EKReminder] = iCloudShoppingList.filter({(reminder : EKReminder) in reminder.alarms != nil})
        
        returnRemindersFunc!(reminderList.map({
            
            (reminder : EKReminder) -> RemindMeItem in
            
            return getReminderItemFrom(reminder)
        }))
    }
    
    func commit() -> Bool {
        
        return icloudReminderManager.commit()
    }

    func getReminderItemFrom(reminder : EKReminder) -> RemindMeItem {
    
        let remindMeItem : RemindMeItem = RemindMeItem()
        
        remindMeItem.title = reminder.title

        if reminder.alarms != nil && reminder.alarms!.count > 0 && reminder.alarms![0].absoluteDate != nil {
        
            remindMeItem.date = reminder.alarms!.first!.absoluteDate!
        }
        
        remindMeItem.id = getReminderId(remindMeItem.title, date: remindMeItem.date!)
        
        return remindMeItem
    }
    
    func getReminderId(reminder : EKReminder) -> String? {
        
        if reminder.alarms != nil && reminder.alarms!.count > 0 && reminder.alarms![0].absoluteDate != nil {
            
            return getReminderId(reminder.title, date: reminder.alarms![0].absoluteDate!)
        }
        
        return nil
    }
    
    func getReminderId(title : String, date : NSDate) -> String {
        
        let dateComponents : NSDateComponents = NSDateManager.getDateComponentsFromDate(date)
        
        return title + NSDateManager.dateStringFromComponents(dateComponents)
    }
}



    
