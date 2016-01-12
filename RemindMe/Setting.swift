//
//  Setting.swift
//  RemindMe
//
//  Created by Stephen Haxby on 5/01/2016.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import Foundation

class Setting : NSObject, NSCoding {
    
    var name : String = ""

    var time : NSDate = NSDate()
    
    convenience init (name : String, time : NSDate) {
        self.init()
        self.name = name
        self.time = time
    }
    
    required convenience init(coder decoder: NSCoder) {
        self.init()
        
        self.name = decoder.decodeObjectForKey("name") as! String
        self.time = decoder.decodeObjectForKey("time") as! NSDate
    }
    
    func encodeWithCoder(coder: NSCoder) {
        
        coder.encodeObject(name, forKey: "name")
        
        coder.encodeObject(time, forKey: "time")
    }
}