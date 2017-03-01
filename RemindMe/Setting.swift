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
    
    var id : String {
        
        get {
            
            return setting.value(forKey: "id") as! String
        }
        set (value) {
            
            setting.setValue(value, forKeyPath: "id")
        }
    }
    
    var name : String {
        get {
            
            return setting.value(forKey: "name") as! String
        }
        set (value) {
            
            setting.setValue(value, forKeyPath: "name")
        }
    }
    
    var latitude : Double? {
        
        get {
            
            return setting.value(forKey: "latitude") as? Double
        }
        set (value) {
            
            setting.setValue(value, forKeyPath: "latitude")
        }
    }
    
    var longitude : Double? {
        
        get {
            
            return setting.value(forKey: "longitude") as? Double
        }
        set (value) {
            
            setting.setValue(value, forKeyPath: "longitude")
        }
    }
    
    var sequence : Int {
        
        get {
            
            return (setting.value(forKey: "sequence") as! NSNumber).intValue
        }
        set (value) {
            
            setting.setValue(NSNumber(value: value as Int), forKeyPath: "sequence")
        }
    }
    
    var time : Date? {
        
        get {
            
            return setting.value(forKey: "time") as? Date
        }
        set (value) {
            
            setting.setValue(value, forKeyPath: "time")
        }
    }
    
    var type : Int {
        
        get {
            
            return (setting.value(forKey: "type") as! NSNumber).intValue
        }
        set (value) {
            
            setting.setValue(NSNumber(value: value as Int), forKeyPath: "type")
        }
    }
    
    init(managedObject : NSManagedObject) {
        
        self.setting = managedObject
    }
}
