//
//  iCloudReminderFacade.swift
//  RemindMe
//
//  Created by Stephen Haxby on 5/01/2016.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//


EKAlarmManager.getFirstAbsoluteDateComponentsFromAlarms(reminderItem.alarms)

return EKAlarm(absoluteDate: reminderDate)
return EKAlarm(absoluteDate: NSDateManager.addDaysToDate(reminderDate, days: 1))


import Foundation

class iCloudReminderFacade : StorageFacadeProtocol {
    
    var icloudReminderManager : iCloudReminderManager {
        
        get {
            return icloudReminderManager!
        }
    }
    
    var returnRemindersFunc : [RemindMeItem] -> () = nil
    
    init (icloudReminderManager : iCloudReminderManager) {
    
        self.icloudReminderManager = icloudReminderManager
        
        // Set the name of the reminder list we are going to use
        icloudReminderManager.remindersListName = Constants.RemindersListName
        
        // Request access to Reminders
        icloudReminderManager.requestAccessToReminders(requestedAccessToReminders)
    }
    
    func createNewReminder() -> RemindMeItem {
    
        return getReminderItemFrom(icloudReminderManager.getNewReminder()!)
    } 
    
    func createNewReminder(name : String, time : NSDate) -> RemindMeItem {
        
        var reminder : EKReminder = icloudReminderManager.getNewReminder()!
        
        reminder.title = name       
        
        var newAlarms : [EKAlarm] = [EKAlarm]()
        newAlarms.append(EKAlarm(absoluteDate: time))        
        newReminder.alarms = newAlarms
        
        return getReminderItemFrom(reminder)
    }

    
    
    
    
    func updateReminder(remindMeItem : RemindMeItem) {
    
        //TODO:
    
        //Need to try and use calendarItemWithIdentifier:
    
        //icloudReminderManager.getReminders(getReminderList)
    
        //var reminder : Reminder = reminderRepository.getReminderBy(remindMeItem.id)
        
        //reminder.title = remindMeItem.title
        //reminder.date = remindMeItem.date
    }
        
    func removeReminder(remindMeItem : RemindMeItem) {
        
        //TODO:
        
        //Need to try and use calendarItemWithIdentifier:
        
        //var reminder : Reminder = reminderRepository.getReminderBy(remindMeItem.id)
        
        //reminderRepository.removeReminder(reminder)
    }
    
    
    
    
    //Expects a function that has a parameter that's an array of RemindMeItem
    func getReminders(returnReminders : [RemindMeItem] -> ()){
    
        returnRemindersFunc = returnReminders
        
        icloudReminderManager.getReminders(getiCloudReminders)
    }
    
    private func getiCloudReminders(iCloudShoppingList : [EKReminder]){
    
        if returnRemindersFunc != nil {
    
            returnRemindersFunc(iCloudShoppingList.map({
                
                (reminder : Reminder) -> RemindMeItem in
                
                return getReminderItemFrom(reminder)
            }))
        }
    }
    
    func commit() -> Bool {
        
        return icloudReminderManager.commit()
    }

    func getReminderItemFrom(reminder : EKReminder) -> RemindMeItem {
    
        var remindMeItem : RemindMeItem = RemindMeItem()
        
        remindMeItem.id = reminder.calendarItemIdentifier
        remindMeItem.title = reminder.title

        if reminder.alarms != nil && reminder.alarms.length > 0 {
        
            remindMeItem.date = reminder.alarms!.first.absoluteDate!
        }
        
        return remindMeItem
    }
}



    

