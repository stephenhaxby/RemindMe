//
//  ReminderFacade.swift
//  RemindMe
//
//  Created by Stephen Haxby on 5/01/2016.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import Foundation

class ReminderFacade : StorageFacadeProtocol {
       
    let localNotificationManager : LocalNotificationManager = LocalNotificationManager()
    
    var reminderRepository : ReminderRepository
    
    init (reminderRepository : ReminderRepository) {
    
        self.reminderRepository = reminderRepository
    }
    
    func createOrUpdateReminder(_ remindMeItem : RemindMeItem) {
    
        var isNewReminder : Bool = false
        
        if let reminder : Reminder = reminderRepository.getReminderBy(remindMeItem.id) {
    
            reminder.title = remindMeItem.title
            reminder.date = remindMeItem.date!
            
            localNotificationManager.setReminderNotification(remindMeItem)
        }
        else {
            
            isNewReminder = true
    
            let reminder : Reminder = reminderRepository.createNewReminder(remindMeItem.title, time : remindMeItem.date!)
            
            let newRemindMeItem : RemindMeItem = getReminderItemFrom(reminder)
            
            localNotificationManager.setReminderNotification(newRemindMeItem)
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: isNewReminder ? Constants.RefreshNotificationScrollToBottom : Constants.RefreshNotification), object: nil)
    }
    
    func removeReminder(_ Id: String) -> Bool {
        
        return reminderRepository.removeReminder(Id)
    }
    
    func removeReminder(_ remindMeItem : RemindMeItem) -> Bool {
        
        localNotificationManager.clearReminderNotification(remindMeItem)
        
        let reminder : Reminder = reminderRepository.getReminderBy(remindMeItem.id)!
        
        return reminderRepository.removeReminder(reminder)
    }
    
    //Expects a function that has a parameter that's an array of RemindMeItem
    func getReminders(_ returnReminders : @escaping ([RemindMeItem]) -> ()){
    
        returnReminders(reminderRepository.getReminders().map({
                
                (reminder : Reminder) -> RemindMeItem in
                
                return getReminderItemFrom(reminder)
            }))
    }
    
    func commit() -> Bool {
        
        return reminderRepository.commit()
    }
    
    func getReminderItemFrom(_ reminder : Reminder) -> RemindMeItem {
    
        let remindMeItem : RemindMeItem = RemindMeItem()
        
        remindMeItem.id = reminder.id
        remindMeItem.title = reminder.title
        remindMeItem.date = reminder.date
        
        return remindMeItem
    }
}



    

