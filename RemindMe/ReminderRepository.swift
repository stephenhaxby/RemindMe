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
        
        let entity = NSEntityDescription.entity(forEntityName: "Reminder", in:managedObjectContext)
        
        let reminderManagedObject = NSManagedObject(entity: entity!, insertInto: managedObjectContext)
        
        return Reminder(managedObject: reminderManagedObject)
    }
    
    func createNewReminder(_ name : String, time : Date) -> Reminder {
        
        let reminder : Reminder = createNewReminder()
        
        reminder.id = UUID().uuidString
        reminder.title = name
        reminder.date = time
        
        return reminder
    }
    
    func getReminderBy(_ id : String) -> Reminder? {
    
        let reminderFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Reminder")
    
        reminderFetch.predicate = NSPredicate(format: "id == %@", id)
    
        do {
        
            let reminders : [Reminder] = (try managedObjectContext.fetch(reminderFetch) as! [NSManagedObject]).map({
                
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
            (try managedObjectContext.fetch(NSFetchRequest(entityName: "Reminder")) ).map({
                
                (managedObject : NSManagedObject) -> Reminder in
                
                return Reminder(managedObject: managedObject)
            })
            
        }
        catch let error as NSError {
            
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return [Reminder]()
    }
    
    func removeReminder(_ Id : String) {
        
        if let reminder = getReminderBy(Id) {
            
            removeReminder(reminder)
        }
    }
    
    func removeReminder(_ reminder : Reminder) {
        
        managedObjectContext.delete(reminder.reminder)
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
