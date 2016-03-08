//
//  ReminderItemSequence.swift
//  RemindMe
//
//  Created by Stephen Haxby on 8/03/2016.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import Foundation

class ReminderItemSequence : NSObject, NSCoding {
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("ReminderItemSequence")
    
    var calendarItemExternalIdentifier : String = ""
    var sequenceNumber : Int = 0
    
    convenience init(calendarItemExternalIdentifier : String, sequenceNumber : Int) {
        self.init()
        
        self.calendarItemExternalIdentifier = calendarItemExternalIdentifier
        self.sequenceNumber = sequenceNumber
    }
    
    required convenience init(coder decoder: NSCoder){
        
        let calendarItemExternalIdentifier : String = decoder.decodeObjectForKey("calendarItemExternalIdentifier") as! String
        let sequenceNumber : Int = decoder.decodeIntegerForKey("sequenceNumber")
        
        self.init(calendarItemExternalIdentifier: calendarItemExternalIdentifier, sequenceNumber: sequenceNumber)
    }
    
    func encodeWithCoder(coder: NSCoder) {
        
        coder.encodeObject(calendarItemExternalIdentifier, forKey: "calendarItemExternalIdentifier")
        
        coder.encodeInteger(sequenceNumber, forKey: "sequenceNumber")
    }
}
