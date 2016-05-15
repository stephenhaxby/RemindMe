//
//  Reminder.swift
//  RemindMe
//
//  Created by Stephen Haxby on 5/01/2016.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import Foundation
import CoreData

class Reminder {
    
    var reminder : NSManagedObject
    
    var id : String {
    
        get {
            
            return reminder.valueForKey("id") as! String
        }
        set (value) {
            
            reminder.setValue(value, forKeyPath: "id")
        }
    }
    
    var title : String {
        get {
            
            return reminder.valueForKey("title") as! String
        }
        set (value) {
            
            reminder.setValue(value, forKeyPath: "title")
        }
    }
    
    var date : NSDate {
        
        get {
            
            return reminder.valueForKey("date") as! NSDate
        }
        set (value) {
            
            reminder.setValue(value, forKeyPath: "date")
        }
    }
    
    init(managedObject : NSManagedObject) {
        
        self.reminder = managedObject
    }
}