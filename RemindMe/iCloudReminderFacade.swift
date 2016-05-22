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
    
    var icloudReminderManager : iCloudReminderManager! = nil
    
    var returnRemindersFunc : ([RemindMeItem] -> ())?
    
    init (icloudReminderManager : iCloudReminderManager) {
    
        self.icloudReminderManager = icloudReminderManager
        
        // Set the name of the reminder list we are going to use
        self.icloudReminderManager.remindersListName = Constants.RemindersListName
        
        // Request access to Reminders
        self.icloudReminderManager.requestAccessToReminders(accessGranted)
    }
    
    func accessGranted(granted : Bool) {
                
    }
    
    func createOrUpdateReminder(remindMeItem : RemindMeItem) {
        
        //let reminderId : String = icloudReminderManager.getReminderId(remindMeItem.title, date: remindMeItem.date!)
        
        icloudReminderManager.getReminder(remindMeItem.id) {
            reminder in
            
            if let matchingReminder : EKReminder = reminder {
                
                matchingReminder.title = remindMeItem.title
                matchingReminder.alarms = [EKAlarm(absoluteDate : remindMeItem.date!)]
                
                self.icloudReminderManager.saveReminder(matchingReminder)
            }
            else {
                
                let reminder : EKReminder = self.icloudReminderManager.getNewReminder()!
        
                reminder.title = remindMeItem.title
        
                var newAlarms : [EKAlarm] = [EKAlarm]()
                newAlarms.append(EKAlarm(absoluteDate: remindMeItem.date!))
                reminder.alarms = newAlarms
                
                self.icloudReminderManager.saveReminder(reminder)
            }
        }
    }
    
    func removeReminder(remindMeItem : RemindMeItem) {
        
        let reminderId : String = icloudReminderManager.getReminderId(remindMeItem.title, date: remindMeItem.date!)
        
        icloudReminderManager.getReminder(reminderId) {
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
        
        remindMeItem.title = reminder.title

        if reminder.alarms != nil && reminder.alarms!.count > 0 {
        
            remindMeItem.date = reminder.alarms!.first!.absoluteDate!
        }
        
        remindMeItem.id = icloudReminderManager.getReminderId(remindMeItem.title, date: remindMeItem.date!)
        
        return remindMeItem
    }
}



    

