//
//  ReminderItemSequence.swift
//  RemindMe
//
//  Created by Stephen Haxby on 8/03/2016.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import Foundation

// Serializable / Archive class to keep track of a reminders sequence
class ReminderItemSequence : NSObject, NSCoding {
    
    var calendarItemExternalIdentifier : String = ""
    var sequenceNumber : Int = 0
    
    convenience init(calendarItemExternalIdentifier : String, sequenceNumber : Int) {
        self.init()
        
        self.calendarItemExternalIdentifier = calendarItemExternalIdentifier
        self.sequenceNumber = sequenceNumber
    }
    
    required convenience init(coder decoder: NSCoder){
        
        let calendarItemExternalIdentifier : String = decoder.decodeObject(forKey: "calendarItemExternalIdentifier") as! String
        let sequenceNumber : Int = decoder.decodeInteger(forKey: "sequenceNumber")
        
        self.init(calendarItemExternalIdentifier: calendarItemExternalIdentifier, sequenceNumber: sequenceNumber)
    }
    
    func encode(with coder: NSCoder) {
        
        coder.encode(calendarItemExternalIdentifier, forKey: "calendarItemExternalIdentifier")
        
        coder.encode(sequenceNumber, forKey: "sequenceNumber")
    }
}
