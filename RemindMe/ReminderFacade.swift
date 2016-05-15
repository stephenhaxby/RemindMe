//
//  ReminderFacade.swift
//  RemindMe
//
//  Created by Stephen Haxby on 5/01/2016.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import Foundation

class ReminderFacade {
    
    var title : String = String()
    
    var date : NSDate = NSDate()
    
    var reminderRepository : ReminderRepository {
        
        get {
            return reminderRepository!
        }
    }
    
    init (reminderRepository : ReminderRepository) {
    
        self.reminderRepository = reminderRepository
    }
    
    func createNewReminder() -> RemindMeItem {
    
        return getReminderItemFrom(reminderRepository.createNewReminder())
    }
    
    func createNewReminder(name : String, time : NSDate) -> RemindMeItem {
        
        return getReminderItemFrom(reminderRepository.createNewReminder(name, time : NSDate))
    }
    
    func updateReminder(remindMeItem : RemindMeItem) {
    
        var reminder : Reminder = reminderRepository.getReminderBy(remindMeItem.id)
        
        reminder.title = remindMeItem.title
        reminder.date = remindMeItem.date
    }
    
    func removeReminder(remindMeItem : RemindMeItem) {
        
        var reminder : Reminder = reminderRepository.getReminderBy(remindMeItem.id)
        
        reminderRepository.removeReminder(reminder)
    }
    
    func getReminders() -> [RemindMeItem] {
        
        reminderRepository.getReminders().map({
                
                (reminder : Reminder) -> RemindMeItem in
                
                return getReminderItemFrom(reminder)
            })
    }
    
    func commit() -> Bool {
        
        return reminderRepository.commit()
    }
    
    func getReminderItemFrom(reminder : Reminder) -> RemindMeItem {
    
        var remindMeItem : RemindMeItem = RemindMeItem()
        
        remindMeItem.id = reminder.id
        remindMeItem.title = reminder.title
        remindMeItem.date = reminder.date
        
        return remindMeItem
    }
}



    

