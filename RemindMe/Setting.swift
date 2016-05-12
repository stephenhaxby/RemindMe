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
    
    var sequence : Int {
        
        get {
            
            return (setting.valueForKey("sequence") as! NSNumber).integerValue
        }
        set (value) {
            
            setting.setValue(NSNumber(integer: value), forKeyPath: "sequence")
        }
    }
    
    init(managedObject : NSManagedObject) {
        
        self.setting = managedObject
    }
}