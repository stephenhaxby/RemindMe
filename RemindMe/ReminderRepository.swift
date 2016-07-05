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
    
    var managedObjectContext : NSManagedObjectContext
    
    init(managedObjectContext : NSManagedObjectContext){
        
        self.managedObjectContext = managedObjectContext
    }
    
    func createNewReminder() -> Reminder {
        
        let entity = NSEntityDescription.entityForName("Reminder", inManagedObjectContext:managedObjectContext)
        
        let reminderManagedObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
        
        return Reminder(managedObject: reminderManagedObject)
    }
    
    func createNewReminder(name : String, time : NSDate) -> Reminder {
        
        let reminder : Reminder = createNewReminder()
        
        reminder.id = NSUUID().UUIDString
        reminder.title = name
        reminder.date = time
        
        return reminder
    }
    
    func getReminderBy(id : String) -> Reminder? {
    
        let reminderFetch = NSFetchRequest(entityName: "Reminder")
    
        reminderFetch.predicate = NSPredicate(format: "id == %@", id)
    
        do {
        
            let reminders : [Reminder] = (try managedObjectContext.executeFetchRequest(reminderFetch) as! [NSManagedObject]).map({
                
                (managedObject : NSManagedObject) -> Reminder in
                
                return Reminder(managedObject: managedObject)
            })
            
            if reminders.count == 1 {
                
                return reminders.first!
            }
        }
        catch {
        
                fatalError("Failed to fetch reminder: \(error)")
        }
        
        return nil
    }
    
    func getReminders() -> [Reminder] {

        do {
        
        return
            (try managedObjectContext.executeFetchRequest(NSFetchRequest(entityName: "Reminder")) as! [NSManagedObject]).map({
                
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
        
        managedObjectContext.deleteObject(reminder.reminder)
    }
    
    func commit() -> Bool {
        
        do {
            
            try managedObjectContext.save()

        } catch let error as NSError  {
            
            print("Could not save \(error), \(error.userInfo)")
            
            return false
        }
        
        return true
    }
}
