//
//  ReminderRepository.swift
//  RemindMe
//
//  Created by Stephen Haxby on 15/03/2016.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import Foundation
import CoreData

class ReminderRepository {
    
    var appDelegate : AppDelegate
    
    init(appDelegate : AppDelegate){
        
        self.appDelegate = appDelegate
    }
    
    func getManagedContext() -> NSManagedObjectContext {
        
        return appDelegate.managedObjectContext
    }
    
    func createNewReminder() -> Reminder {
        
        let entity = NSEntityDescription.entityForName("Reminder", inManagedObjectContext:getManagedContext())
        
        let reminderManagedObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: getManagedContext())
        
        return Reminder(managedObject: reminderManagedObject)
    }
    
    func createNewReminder(name : String, time : NSDate) -> Reminder {
        
        let reminder : Reminder = createNewReminder()
        
        reminder.id = NSUUID().UUIDString
        reminder.name = name
        reminder.time = time
        
        return reminder
    }
    
    func getReminderBy(id : String) -> Reminder {
    
        let reminderFetch = NSFetchRequest(entityName: "Reminder")
    
        reminderFetch.predicate = NSPredicate(format: "id == %@", id)
    
        do {
        
            let reminders = try getManagedContext().executeFetchRequest(reminderFetch) as! [Reminder]
            
            if reminders.count == 1 {
            
                return reminders.first
            }
            else {
                
                //TODO: Some kind of error...
            }
        } catch {
        
            fatalError("Failed to fetch reminder: \(error)")
        }
    }
    
    func getReminders() -> [Reminder] {

        do {
        
        return
            (try getManagedContext().executeFetchRequest(NSFetchRequest(entityName: "Reminder")) as! [NSManagedObject]).map({
                
                (managedObject : NSManagedObject) -> Reminder in
                
                return Reminder(managedObject: managedObject)
            })
            
        }
        catch let error as NSError {
            
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return [Reminder]()
    }
    
    func removeReminder(reminder : Reminder) {
        
        getManagedContext().deleteObject(reminder.reminder)
    }
    
    func commit() -> Bool {
        
        do {
            
            try getManagedContext().save()

        } catch let error as NSError  {
            
            //TODO: A better error...
            print("Could not save \(error), \(error.userInfo)")
            
            return false
        }
        
        return true
    }
}
