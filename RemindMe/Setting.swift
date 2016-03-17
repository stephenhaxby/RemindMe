//
//  Setting.swift
//  RemindMe
//
//  Created by Stephen Haxby on 5/01/2016.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import Foundation
import CoreData

class Setting {
    
    var setting : NSManagedObject
    
    var name : String {
        get {
            
            return setting.valueForKey("name") as! String
        }
        set (value) {
            
            setting.setValue(value, forKeyPath: "name")
        }
    }
    
    var time : NSDate {
        
        get {
            
            return setting.valueForKey("time") as! NSDate
        }
        set (value) {
            
            setting.setValue(value, forKeyPath: "time")
        }
    }
    
    init(managedObject : NSManagedObject) {
        
        self.setting = managedObject
    }
}

//// Implement the NSCoding stuff so we can save it into the user defaults using the keyed archiver
//class SettingTEST : NSObject, NSCoding {
//    
//    var name : String = ""
//
//    var time : NSDate = NSDate()
//    
//    convenience init (name : String, time : NSDate) {
//        self.init()
//        
//        self.name = name
//        self.time = time
//    }
//    
//    // Unarchives the data when the class is created
//    // The 'required' keyword means this initiliser must be implemented on every subclass of the class that defines this initializer
//    // The 'convenience' keyword means this initiliser is a secondary, supporting initialiser and it needs to call a super class initiliser.
//    required convenience init(coder decoder: NSCoder) {
//        
//        let name = decoder.decodeObjectForKey("name") as! String
//        let time = decoder.decodeObjectForKey("time") as! NSDate
//        
//        self.init(name: name, time: time)
//    }
//    
//    // Prepares the class's information to be archived
//    func encodeWithCoder(coder: NSCoder) {
//        
//        // Encodes the object
//        coder.encodeObject(name, forKey: "name")
//        
//        coder.encodeObject(time, forKey: "time")
//    }
//}