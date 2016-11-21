//
//  ReminderItemSequence.swift
//  RemindMe
//
//  Created by Stephen Haxby on 8/03/2016.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import Foundation

class ReminderItemSequence : NSObject, NSCoding {
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("ReminderItemSequence")
    
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
