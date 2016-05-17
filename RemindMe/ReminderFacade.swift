//
//  ReminderFacade.swift
//  RemindMe
//
//  Created by Stephen Haxby on 5/01/2016.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import Foundation

class ReminderFacade : StorageFacadeProtocol {
    
    var reminderRepository : ReminderRepository
    
    init (reminderRepository : ReminderRepository) {
    
        self.reminderRepository = reminderRepository
    }
    
    func createNewReminder() -> RemindMeItem {
    
        return getReminderItemFrom(reminderRepository.createNewReminder())
    }
    
    func createNewReminder(name : String, time : NSDate) -> RemindMeItem {
        
        return getReminderItemFrom(reminderRepository.createNewReminder(name, time : NSDate()))
    }
    
    func updateReminder(remindMeItem : RemindMeItem) {
    
        let reminder : Reminder = reminderRepository.getReminderBy(remindMeItem.id)!
        
        reminder.title = remindMeItem.title
        reminder.date = remindMeItem.date!
    }
    
    func removeReminder(remindMeItem : RemindMeItem) {
        
        let reminder : Reminder = reminderRepository.getReminderBy(remindMeItem.id)!
        
        reminderRepository.removeReminder(reminder)
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



    

