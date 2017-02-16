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
            reminder.date = remindMeItem.date
            reminder.latitude = remindMeItem.latitude
            reminder.longitude = remindMeItem.longitude
            reminder.type = remindMeItem.type.rawValue
            reminder.label = remindMeItem.label
            
            localNotificationManager.setReminderNotification(remindMeItem)
        }
        else {
            
            isNewReminder = true
    
            let reminder : Reminder = reminderRepository.createNewReminder(
                remindMeItem.title,
                time : remindMeItem.date,
                latitude : remindMeItem.latitude,
                longitude : remindMeItem.longitude,
                type : remindMeItem.type.rawValue,
                label : remindMeItem.label)
            
            let newRemindMeItem : RemindMeItem = getReminderItemFrom(reminder)
            
            localNotificationManager.setReminderNotification(newRemindMeItem)
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: isNewReminder ? Constants.RefreshNotificationScrollToBottom : Constants.RefreshNotification), object: nil)
    }
    
    func removeReminder(_ Id: String) -> Bool {
        
        return reminderRepository.removeReminder(Id)
    }
    
    func removeReminder(_ remindMeItem : RemindMeItem) -> Bool {
        
        localNotificationManager.clearReminderNotification(remindMeItem: remindMeItem)
        
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
    
        let remindMeItem = RemindMeItem()
        remindMeItem.id = reminder.id
        remindMeItem.title = reminder.title
        remindMeItem.label = reminder.label

        switch reminder.type {
            case Constants.ReminderType.dateTime.rawValue:
                
                guard reminder.date != nil else {
                    
                    Utilities().diaplayError(message: "No reminder date could be found for \(remindMeItem.title)")
                    break
                }
               
                remindMeItem.set(date: reminder.date!)
            
            case Constants.ReminderType.location.rawValue:
                
                guard reminder.latitude != nil && reminder.longitude != nil else {
                    
                    Utilities().diaplayError(message: "No reminder date could be found for \(remindMeItem.title)")
                    break
                }
            
                remindMeItem.set(latitude: reminder.latitude!, longitude: reminder.longitude!)
            
            default:
                break
        }
        
        return remindMeItem
    }
}



    

