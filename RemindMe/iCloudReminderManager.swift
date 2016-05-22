//
//  iCloudReminderManager.swift
//  ReminderSorter
//
//  Created by Stephen Haxby on 3/09/2015.
//  Copyright (c) 2015 Stephen Haxby. All rights reserved.
//

import EventKit

class iCloudReminderManager{
    
    var eventStoreAccessGranted = false
    let eventStore = EKEventStore()
    var remindersListName = "Reminders"
    var reminderList : EKCalendar?
    
    //Requests access to reminders. Takes in a function to find if access has been granted or not.
    //We can then perform some action like stop a refresh control...
    func requestAccessToReminders(accessStatus : Bool -> ()){
        
        if(!eventStoreAccessGranted){
            
            //Request access to the users Reminders
            eventStore.requestAccessToEntityType(EKEntityType.Reminder, completion: {
                granted, error in
                
                //Save the 'granted' value - if we were granted access
                self.eventStoreAccessGranted = granted
                
                self.getReminderList()
                
                accessStatus(granted)
            })
        }
    }
    
    //Return our specified reminders list (by name = remindersListName)
    func getReminderList() -> EKCalendar?{
        
        if(eventStoreAccessGranted){
            
            if(reminderList == nil){
  
                //Get the Reminders
                let calendars = eventStore.calendarsForEntityType(EKEntityType.Reminder) 
                
                var reminderListCalendars = calendars.filter({(calendar : EKCalendar) in calendar.title == self.remindersListName})
                
                if(reminderListCalendars.count == 1) {
                    
                    reminderList = reminderListCalendars[0];
                }
                else if(reminderListCalendars.count > 1) {
                    
                    return nil
                }
                else {
                    
                    reminderList = EKCalendar(forEntityType: EKEntityType.Reminder, eventStore: eventStore)
                    
                    //Save the new calendar
                    reminderList!.title = remindersListName;
                    reminderList!.source = eventStore.defaultCalendarForNewReminders().source
                    
                    do {
                        
                        try eventStore.saveCalendar(reminderList!, commit: true)
                        
                    } catch _ as NSError {
                      
                        return nil
                    }
                }
            }
            
            return reminderList
        }
        
        return nil
    }
    
    func getReminders(returnReminders : [EKReminder] -> ()){
        
        var remindersList = [EKReminder]()
        
        if(eventStoreAccessGranted && reminderList != nil){
            
            let singlecallendarArrayForPredicate : [EKCalendar] = [reminderList!]
            let predicate = eventStore.predicateForRemindersInCalendars(singlecallendarArrayForPredicate)
            
            //Get all the reminders for the above search predicate
            eventStore.fetchRemindersMatchingPredicate(predicate) { reminders in
                
                if let matchingReminders = reminders {
                    
                    //For each reminder in iCloud
                    for reminder in matchingReminders {
                        
                        remindersList.append(reminder)
                    }
                }
                
                returnReminders(remindersList)
            }
        }
    }
    
    TODO: Need to create an ID frm the title and date then use that to find reminders

    func getReminder(title : String, date : NSDate, returnReminder : EKReminder? -> ()) -> EKReminder? {
    
        var remindersList = [EKReminder]()
        
        if(eventStoreAccessGranted && reminderList != nil){
            
            let singlecallendarArrayForPredicate : [EKCalendar] = [reminderList!]
            let predicate = eventStore.predicateForRemindersInCalendars(singlecallendarArrayForPredicate)
            
            //Get all the reminders for the above search predicate
            eventStore.fetchRemindersMatchingPredicate(predicate) { reminders in
                
                if let matchingReminders = reminders {
                    
                    //For each reminder in iCloud
                    for reminder in matchingReminders {
                        
                        remindersList.append(reminder)
                    }
                }
                
                var foundReminder : EKReminder?
                
                if let index = remindersList.indexOf({ (reminder : EKReminder) in reminder.title == title && reminder.hasAlarms && NSDateManager.timeIsEqualToTime(date, date2: reminder.alarms![0].absoluteDate!)}) {

                    foundReminder = remindersList[index]
                }
                
                returnReminder(foundReminder)
            }
        }

        return nil
    }
    
    func addReminder(title : String) -> EKReminder? {
        
        let calendar : EKCalendar? = getReminderList()
        
        guard calendar != nil else {
            
            return nil
        }
        
        let reminder:EKReminder = EKReminder(eventStore: eventStore)
        reminder.title = title
        reminder.calendar = calendar!
        
        do {
            
            try eventStore.saveReminder(reminder, commit: true)
            
        } catch {

            return nil
        }
        
        return reminder
    }
    
    func saveReminder(reminder : EKReminder) -> Bool {
        
        return saveReminder(reminder, commit: true)
    }
    
    func saveReminder(reminder : EKReminder, commit : Bool) -> Bool {
     
        do {
            
            try eventStore.saveReminder(reminder, commit: commit)
            
        } catch let error as NSError {
            
            //That event does not belong to that event store (error.code == 11).
            guard error.code == 11 else {
                
                return false
            }
        }
        
        return true
    }
    
    func removeReminder(reminder : EKReminder) -> Bool {
        
        return removeReminder(reminder, commit: true)
    }
    
    func removeReminder(reminder : EKReminder, commit : Bool) -> Bool {
        
        do {
            
            try eventStore.removeReminder(reminder, commit: commit)
            
            return true
            
        } catch {
            
            return false
        }
    }
    
    func commit() -> Bool {
    
        do {
        
            try eventStore.commit()
            
            return true
        }
        catch {

            return false
        }
    }
    
    func getNewReminder() -> EKReminder? {
        
        if reminderList != nil
        {
            let reminder : EKReminder = EKReminder(eventStore: eventStore)
            reminder.calendar = reminderList!
            
            return reminder
        }
        
        return nil
    }
    
    func cloneReminder(reminder : EKReminder) -> EKReminder? {
        
        let calendar : EKCalendar? = getReminderList()
        
        guard calendar != nil else {
            
            return nil
        }
        
        let newReminder : EKReminder = EKReminder(eventStore: eventStore)
        newReminder.calendar = calendar!
        newReminder.title = reminder.title
        
        var newAlarms : [EKAlarm] = [EKAlarm]()

        for reminder in reminder.alarms! {
            
            newAlarms.append(EKAlarm(absoluteDate: reminder.absoluteDate!))
        }
        
        newReminder.alarms = newAlarms
        
        return newReminder
    }
}