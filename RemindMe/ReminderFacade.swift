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
    
    func createOrUpdateReminder(remindMeItem : RemindMeItem) {
    
        if let reminder : Reminder = reminderRepository.getReminderBy(remindMeItem.id) {
    
            reminder.title = remindMeItem.title
            reminder.date = remindMeItem.date!
        }
            else {
        
                reminderRepository.createNewReminder(remindMeItem.title, time : remindMeItem.date!)
        
                localNotificationManager.setReminderNotification(remindMeItem)
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.RefreshNotificationName, object: nil)
    }
    
    func removeReminder(remindMeItem : RemindMeItem) {
        
        let reminder : Reminder = reminderRepository.getReminderBy(remindMeItem.id)!
        
        reminderRepository.removeReminder(reminder)
        
        localNotificationManager.clearReminderNotification(remindMeItem)
        
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.RefreshNotificationName, object: nil)
    }
    
    //Expects a function that has a parameter that's an array of RemindMeItem
    func getReminders(returnReminders : [RemindMeItem] -> ()){
    
        returnReminders(reminderRepository.getReminders().map({
                
                (reminder : Reminder) -> RemindMeItem in
                
                return getReminderItemFrom(reminder)
            }))
    }
    
    func commit() -> Bool {
        
        return reminderRepository.commit()
    }
    
    func getReminderItemFrom(reminder : Reminder) -> RemindMeItem {
    
        let remindMeItem : RemindMeItem = RemindMeItem()
        
        remindMeItem.id = reminder.id
        remindMeItem.title = reminder.title
        remindMeItem.date = reminder.date
        
        return remindMeItem
    }
}



    

