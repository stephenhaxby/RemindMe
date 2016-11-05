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
            
            return reminder.value(forKey: "id") as! String
        }
        set (value) {
            
            reminder.setValue(value, forKeyPath: "id")
        }
    }
    
    var title : String {
        get {
            
            return reminder.value(forKey: "title") as! String
        }
        set (value) {
            
            reminder.setValue(value, forKeyPath: "title")
        }
    }
    
    var date : Date {
        
        get {
            
            return reminder.value(forKey: "date") as! Date
        }
        set (value) {
            
            reminder.setValue(value, forKeyPath: "date")
        }
    }
    
    var latitude : Double {
        
        get {
            
            return Double(reminder.value(forKey: "latitude") as! NSNumber)
        }
        set (value) {
            
            reminder.setValue(value, forKeyPath: "latitude")
        }
    }
    
    var longitude : Double {
        
        get {
            
            return Double(reminder.value(forKey: "longitude") as! NSNumber)
        }
        set (value) {
            
            reminder.setValue(value, forKeyPath: "longitude")
        }
    }
    
    var type : Int {
        
        get {
            
            return (reminder.value(forKey: "type") as! NSNumber).intValue
        }
        set (value) {
            
            reminder.setValue(NSNumber(value: value as Int), forKeyPath: "type")
        }
    }
    
    var label : String {
        get {
            
            return reminder.value(forKey: "label") as! String
        }
        set (value) {
            
            reminder.setValue(value, forKeyPath: "label")
        }
    }
    
    init(managedObject : NSManagedObject) {
        
        self.reminder = managedObject
    }
}
